#define WORLD_WRITABLE_MODEL 1
#import <SPSuccinct/SPSuccinct.h>
#import "TankGame.h"
#import "TankPlayer.h"
#import "TankTank.h"
#import "TankEnemyTank.h"
#import "TankLevel.h"
#import "TankBullet.h"
#import "BNZLine.h"
#import "TankTankController.h"

@implementation TankGame
- (id)init
{
	if(self = [super init]) {
		_enemyTanks = [NSMutableArray array];
	}
	return self;
}

- (NSDictionary*)rep
{
    return WorldDictAppend([super rep], @{
		@"currentLevel": self.currentLevel.identifier ?: [NSNull null],
	});
}
- (void)updateFromRep:(NSDictionary*)rep fetcher:(WorldEntityFetcher)fetcher
{
    [super updateFromRep:rep fetcher:fetcher];
    WorldIf(rep, @"currentLevel", ^(id o) {
		self.currentLevel = [o isEqual:[NSNull null]] ? nil : fetcher(o, [TankLevel class], NO);
    });
}

- (void)tick:(float)delta
{
	for(TankTank *tank in [self.players valueForKeyPath:@"tank"]) {
        [tank.tankController tickWithTank:tank delta:delta];
        
		tank.velocity = [[tank.velocity vectorByAddingVector:[tank.acceleration vectorByMultiplyingWithScalar:delta]] vectorByMultiplyingWithScalar:0.9];
		tank.position = [tank.position vectorByAddingVector:[tank.velocity vectorByMultiplyingWithScalar:delta]];
		tank.angularVelocity = (tank.angularVelocity + tank.angularAcceleration*delta)*0.4;
		tank.rotation = tank.rotation + tank.angularVelocity*delta;
	}
	
	for(TankBullet *bullet in [self.currentLevel.bullets copy]) {
		Vector2 *oldPosition = bullet.position;
		bullet.position = [bullet.position vectorByAddingVector:[[Vector2 vectorWithX:0 y:delta*bullet.speed] vectorByRotatingByRadians:bullet.angle]];
		BNZLine *movement = [BNZLine lineAt:oldPosition to:bullet.position];
		for(BNZLine *wall in _currentLevel.walls) {
			Vector2 *collision;
			if([wall getIntersectionPoint:&collision withLine:movement] == BNZLinesIntersect) {
				bullet.collisionTTL -= 1;
				if(bullet.collisionTTL == 0) {
					[[self.currentLevel mutableArrayValueForKey:@"bullets"] removeObject:bullet];
					break;
				}
				Vector2 *collisionVector = [[[BNZLine lineAt:oldPosition to:collision] vector] invertedVector];
				Vector2 *paddleVector = [wall vector];
				Vector2 *normal = [paddleVector rightHandNormal];
				Vector2 *mirror = [collisionVector vectorByProjectingOnto:normal];
				Vector2 *lefty = [collisionVector vectorBySubtractingVector:mirror];
				Vector2 *righty = [lefty invertedVector];
				Vector2 *outgoingVector = [mirror vectorByAddingVector:righty];
				Vector2 *newBallPos = [collision vectorByAddingVector:outgoingVector];
				bullet.position = newBallPos;
				bullet.angle = [outgoingVector angle] - M_PI_2;
				break;
			}
		}
		
		
	}
  
  // Update enemies!!
  for (TankEnemyTank *enemyTank in self.enemyTanks) {
    TankTank *closestPlayer = [self closestPlayerToPosition:enemyTank.position];
    enemyTank.aimingAt = closestPlayer.position;
    
    // Should fire?
    if (enemyTank.timeSinceFire > 0.25f && [enemyTank.position distance:closestPlayer.position] < 500) {
      
      TankBullet *bullet = [TankBullet new];
      bullet.speed = 1000;
      bullet.collisionTTL = 2;
      [[self.currentLevel mutableArrayValueForKey:@"bullets"] addObject:bullet];
      bullet.position = enemyTank.position;
      bullet.angle = enemyTank.turretRotation + enemyTank.rotation;
      
      enemyTank.timeSinceFire = 0.0f;
    }
    
    enemyTank.timeSinceFire += delta;
  }
}

- (TankTank*) closestPlayerToPosition:(Vector2*)pos {
  
  TankTank *closestPlayer = NULL;
  float closestDistance = 0;
  for (TankTank *tank in [self.players valueForKeyPath:@"tank"]) {
    float distance = [pos distance:tank.position];
    if (!closestPlayer || distance < closestDistance) {
      closestPlayer = tank;
      closestDistance = distance;
    }
  }
  
  return closestPlayer;
}
@end

@implementation TankGameServer
- (void)awakeFromPublish
{
	[super awakeFromPublish];
	
	self.currentLevel = [TankLevel new];
    
	[self sp_addObserver:self forKeyPath:@"players" options:NSKeyValueObservingOptionInitial callback:^(NSDictionary *change, id object, NSString *keyPath) {
		for(TankPlayer *player in [object players]) {
			if (!player.tank) {
				player.tank = [TankTank new];
				[[self.currentLevel mutableArrayValueForKey:@"tanks"] addObject:player.tank];
			}
		}
	}];
	
	for(int i = 0; i < 2; i++) {
        TankEnemyTank *enemyTank = [[TankEnemyTank alloc] init];
        enemyTank.position = [Vector2 vectorWithX:300+(200*(i+1)) y:300*(i+1)];

		[[self.currentLevel mutableArrayValueForKey:@"tanks"] addObject:enemyTank];
        [[self mutableArrayValueForKey:@"enemyTanks"] addObject:enemyTank];
	}
}
@end

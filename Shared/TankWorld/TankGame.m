#define WORLD_WRITABLE_MODEL 1
#import <SPSuccinct/SPSuccinct.h>
#import "TankGame.h"
#import "TankPlayer.h"
#import "TankTank.h"
#import "TankEnemyTank.h"
#import "TankLevel.h"
#import "TankBullet.h"
#import "BNZLine.h"

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
        if([tank.moveIntent length]) {
            if(tank.canMove) {
                tank.position = [tank.position vectorByAddingVector:[tank.moveIntent vectorByMultiplyingWithScalar:delta * tankMaxSpeed]];
            } else {
                // Rotate towards the intended direction
                Vector2 *look = [[Vector2 vectorWithX:0 y:1] vectorByRotatingByRadians:tank.rotation];
                
                // Goals are relative to look dir!
                
                // Angle to move intent, from up
                float goal1 = [look angleTo:tank.moveIntent];
                
                // Angle to inversed move intent, from up
                float goal2 = [look angleTo:[tank.moveIntent invertedVector]];
                
                float goal = fabsf(goal1) < fabsf(goal2) ? goal1 : goal2;
              
                if(goal < 0)
                    tank.rotation -= tankRotationSpeed * delta;
                else
                    tank.rotation += tankRotationSpeed * delta;
                
                if(goal > -0.001 && goal < 0.001)
                    tank.canMove = YES;
            }
        }
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
	if(!closestPlayer)
		continue;
    enemyTank.aimingAt = closestPlayer.position;
    
    // Should fire?
    if (enemyTank.timeSinceFire > 3.f && [enemyTank.position distance:closestPlayer.position] < 250) {
      
      TankBullet *bullet = [TankBullet new];
      bullet.speed = TankBulletStandardSpeed;
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

- (void)cmd_aimTankAt:(Vector2*)aimAt;
{
	[self sendCommandToCounterpart:@"aimTankAt" arguments:@{
		@"aimAt": aimAt.rep,
	}];
}

- (void)cmd_fire
{
	[self sendCommandToCounterpart:@"fire" arguments:@{}];
}

- (void)cmd_moveTank:(PlayerInputState*)state
{
	[self sendCommandToCounterpart:@"moveTank" arguments:@{
		@"state": state.rep,
	}];
}


@end

@implementation TankGameServer
- (void)awakeFromPublish
{
	[super awakeFromPublish];
	
	self.currentLevel = [TankLevel new];
    
	__weak __typeof(self) weakSelf = self;
	[self sp_observe:@"players" removed:^(TankPlayer *player) {
		[[weakSelf.currentLevel mutableArrayValueForKey:@"tanks"] removeObject:player.tank];
	} added:^(TankPlayer *player) {
		if (!player.tank) {
			player.tank = [TankTank new];
			[[weakSelf.currentLevel mutableArrayValueForKey:@"tanks"] addObject:player.tank];
		}
	} initial:YES];
	
	for(int i = 0; i < 2; i++) {
        TankEnemyTank *enemyTank = [[TankEnemyTank alloc] init];
        enemyTank.position = [Vector2 vectorWithX:300+(100*(i+1)) y:200+100*(i+1)];

		[[self.currentLevel mutableArrayValueForKey:@"tanks"] addObject:enemyTank];
        [[self mutableArrayValueForKey:@"enemyTanks"] addObject:enemyTank];
	}
}

- (void)commandFromPlayer:(TankPlayer*)player aimTankAt:(NSDictionary*)args
{
	player.tank.aimingAt = [[Vector2 alloc] initWithRep:args[@"aimAt"]];
}

- (void)commandFromPlayer:(TankPlayer*)player fire:(NSDictionary*)args
{
	TankBullet *bullet = [TankBullet new];
	bullet.speed = TankBulletStandardSpeed;
	bullet.collisionTTL = 2;
	bullet.position = player.tank.position;
	bullet.angle = player.tank.turretRotation + player.tank.rotation;
	[[self.currentLevel mutableArrayValueForKey:@"bullets"] addObject:bullet];
}

- (void)commandFromPlayer:(TankPlayer*)player moveTank:(NSDictionary*)args
{
	TankTank *playerTank = player.tank;
	
	PlayerInputState *state = [[PlayerInputState alloc] initWithRep:args[@"state"]];
	
    if(state.up)
        playerTank.moveIntent = [Vector2 vectorWithX:playerTank.moveIntent.x y:1.0f];
    else if (state.down)
        playerTank.moveIntent = [Vector2 vectorWithX:playerTank.moveIntent.x y:-1.0f];
    else
        playerTank.moveIntent = [Vector2 vectorWithX:playerTank.moveIntent.x y:0];

    if(state.right)
        playerTank.moveIntent = [Vector2 vectorWithX:1.0f y:playerTank.moveIntent.y];
    else if(state.left)
        playerTank.moveIntent = [Vector2 vectorWithX:-1.0f y:playerTank.moveIntent.y];
    else
        playerTank.moveIntent = [Vector2 vectorWithX:0 y:playerTank.moveIntent.y];

    // Normalize so we don't go faster diagonally
    if([playerTank.moveIntent length] > 0.0)
        playerTank.moveIntent = [playerTank.moveIntent normalizedVector];
    
    // Something changed, so force recalc of canMove
    playerTank.canMove = NO;
}

@end

@implementation PlayerInputState
- (NSDictionary*)rep
{
	return @{
		@"up": @(_up),
		@"right": @(_right),
		@"down": @(_down),
		@"left": @(_left),
	};
}
- (id)initWithRep:(NSDictionary*)rep
{
	if(self = [super init]) {
		self.up = [rep[@"up"] boolValue];
		self.right = [rep[@"right"] boolValue];
		self.down = [rep[@"down"] boolValue];
		self.left = [rep[@"left"] boolValue];
	}
	return self;
}

@end
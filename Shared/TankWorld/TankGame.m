#define WORLD_WRITABLE_MODEL 1
#import <SPSuccinct/SPSuccinct.h>
#import <PhysicsKit/PhysicsKit.h>
#import "TankGame.h"
#import "TankPlayer.h"
#import "TankTank.h"
#import "TankEnemyTank.h"
#import "TankLevel.h"
#import "TankBullet.h"
#import "BNZLine.h"

@interface TankGame () <PKPhysicsContactDelegate>
@property(nonatomic,strong) PKPhysicsWorld *world;
@end

@implementation TankGame
- (id)init
{
	if(self = [super init]) {
		_enemyTanks = [NSMutableArray array];
        _world = [[PKPhysicsWorld alloc] init];
        _world.contactDelegate = self;
        _world.gravity = CGPointZero;
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
    NSArray *physicalEntities = [self.currentLevel.tanks arrayByAddingObjectsFromArray:self.currentLevel.bullets];
	for(TankPhysicalEntity *ent in physicalEntities) {
        if(!ent.physicsBody._world)
            [_world addBody:ent.physicsBody];
        [ent applyForces];
    }
    
    [_world stepWithTime:delta velocityIterations:10 positionIterations:10];
	
	for(TankPhysicalEntity *ent in physicalEntities)
        [ent updatePropertiesFromPhysics];
  
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
      bullet.rotation = enemyTank.turretRotation + enemyTank.rotation;
      [bullet updatePhysicsFromProperties];
      
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

- (void)didBeginContact:(PKPhysicsContact *)contact
{
    NSArray *bullets = self.currentLevel.bullets;
    NSArray *bulletBodies = [bullets valueForKeyPath:@"physicsBody"];
    PKPhysicsBody *body = [contact bodyA];
//    PKPhysicsBody *other = [contact bodyB];
    if(![bulletBodies containsObject:body])
        body = [contact bodyB];
    if(![bulletBodies containsObject:body])
        return;
    
    TankBullet *bullet = bullets[[bulletBodies indexOfObject:body]];
    if(--bullet.collisionTTL == 0) {
        [self.world removeBody:body];
        [[self.currentLevel mutableArrayValueForKey:@"bullets"] removeObject:bullet];
    }
}

@end

@implementation TankGameServer
- (void)awakeFromPublish
{
	[super awakeFromPublish];
	
	self.currentLevel = [TankLevel new];
    [self.currentLevel addWallsToPhysics:self.world];
    
	__weak __typeof(self) weakSelf = self;
	[self sp_observe:@"players" removed:^(TankPlayer *player) {
		[[weakSelf.currentLevel mutableArrayValueForKey:@"tanks"] removeObject:player.tank];
	} added:^(TankPlayer *player) {
		if (!player.tank) {
			player.tank = [TankTank new];
            [player.tank updatePhysicsFromProperties];
			[[weakSelf.currentLevel mutableArrayValueForKey:@"tanks"] addObject:player.tank];
		}
	} initial:YES];
	
	for(int i = 0; i < 2; i++) {
        TankEnemyTank *enemyTank = [[TankEnemyTank alloc] init];
        enemyTank.position = [Vector2 vectorWithX:300+(100*(i+1)) y:200+100*(i+1)];
        [enemyTank updatePhysicsFromProperties];

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
	bullet.rotation = player.tank.turretRotation + player.tank.rotation;
    [bullet updatePhysicsFromProperties];
	[[self.currentLevel mutableArrayValueForKey:@"bullets"] addObject:bullet];
}

- (void)commandFromPlayer:(TankPlayer*)player moveTank:(NSDictionary*)args
{
	TankTank *playerTank = player.tank;
	
	PlayerInputState *state = [[PlayerInputState alloc] initWithRep:args[@"state"]];
	
    if (state.forward && !state.reverse)
        playerTank.acceleration = [[Vector2 vectorWithX:0 y:100] vectorByRotatingByRadians:playerTank.rotation];
    
    if (state.reverse && !state.forward)
        playerTank.acceleration = [[Vector2 vectorWithX:0 y:-100] vectorByRotatingByRadians:playerTank.rotation];
    
    if (!state.reverse && !state.forward)
        playerTank.acceleration = [Vector2 zero];
    
    
    if (state.turnLeft && !state.turnRight)
        playerTank.angularAcceleration = 0.1;
    
    if (state.turnRight && !state.turnLeft)
        playerTank.angularAcceleration = -0.1;
    
    if (!state.turnLeft && !state.turnRight)
        playerTank.angularAcceleration = 0;
}

@end

@implementation PlayerInputState
- (NSDictionary*)rep
{
	return @{
		@"forward": @(_forward),
		@"reverse": @(_reverse),
		@"turnLeft": @(_turnLeft),
		@"turnRight": @(_turnRight),
	};
}
- (id)initWithRep:(NSDictionary*)rep
{
	if(self = [super init]) {
		self.forward = [rep[@"forward"] boolValue];
		self.reverse = [rep[@"reverse"] boolValue];
		self.turnLeft = [rep[@"turnLeft"] boolValue];
		self.turnRight = [rep[@"turnRight"] boolValue];
	}
	return self;
}

@end
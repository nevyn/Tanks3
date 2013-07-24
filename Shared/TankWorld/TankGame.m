#define WORLD_WRITABLE_MODEL 1
#import <SPSuccinct/SPSuccinct.h>
#import <SpriteKit/SpriteKit.h>
#import "TankGame.h"
#import "TankPlayer.h"
#import "TankTank.h"
#import "TankEnemyTank.h"
#import "TankLevel.h"
#import "TankBullet.h"
#import "BNZLine.h"
#import "SKPhysics+Private.h"

@interface TankGame () <SKPhysicsContactDelegate>

@end

@implementation TankGame
- (id)init
{
	if(self = [super init]) {
		_enemyTanks = [NSMutableArray array];
        _world = [[SKPhysicsWorld alloc] init];
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

- (NSArray*)physicalEntities
{
    return [self.currentLevel.tanks arrayByAddingObjectsFromArray:self.currentLevel.bullets];
}
+ (NSSet*)keyPathsForValuesAffectingPhysicalEntities
{
    return [NSSet setWithArray:@[@"currentLevel.tanks", @"currentLevel.bullets"]];
}

- (void)tick:(float)delta
{
	for(TankTank *tank in [self.players valueForKeyPath:@"tank"]) {
        if([tank.moveIntent length]) {
            if(!tank.canMove) {
                // Rotate
                
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

	for(TankPhysicalEntity *ent in self.physicalEntities)
        [ent applyForces];
    
    [_world stepWithTime:delta velocityIterations:10 positionIterations:10];
	
	for(TankPhysicalEntity *ent in self.physicalEntities)
        [ent updatePropertiesFromPhysics];
  
  // Update enemies!!
  for (TankEnemyTank *enemyTank in self.enemyTanks) {
	  [enemyTank update:delta game:self];
  }
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

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    NSArray *bullets = self.currentLevel.bullets;
    NSArray *bulletBodies = [bullets valueForKeyPath:@"physicsBody"];
    SKPhysicsBody *body = [contact bodyA];
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
    
    [self sp_addObserver:self forKeyPath:@"physicalEntities" options:NSKeyValueObservingOptionOld selector:@selector(setupPhysicsBodiesWithChange:)];
}

- (void)setupPhysicsBodiesWithChange:(NSDictionary*)change
{
    NSArray *olds = change[NSKeyValueChangeOldKey];
    NSArray *news = [self physicalEntities];
    for(TankPhysicalEntity *old in olds) {
        if(![news containsObject:old] && old.physicsBody) {
            [self.world removeBody:old.physicsBody];
            SKPhysicsBodySetUserData(old.physicsBody, nil);
        }
    }
    for(TankPhysicalEntity *new in news) {
        if(new.physicsBody && !new.physicsBody._world) {
            [self.world addBody:new.physicsBody];
            SKPhysicsBodySetUserData(new.physicsBody, new);
        }
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
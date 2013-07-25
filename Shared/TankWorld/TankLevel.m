#define WORLD_WRITABLE_MODEL 1
#import "TankLevel.h"
#import <SPSuccinct/SPSuccinct.h>
#import "BNZLine.h"
#import "SKPhysics+Private.h"
#import "TankTypes.h"
#import "TankLevelMap.h"
#import "TankPhysicalEntity.h"
#import "TankEnemyTank.h"
#import "TankMine.h"
#import "TankPlayer.h"

@interface TankLevelServer : TankLevel
@end

@interface TankLevel () <SKPhysicsContactDelegate>
@end

@implementation TankLevel
- (id)init
{
	if(self = [super init]) {
		_bullets = [NSMutableArray new];
        _mines = [NSMutableArray new];
		_enemyTanks = [NSMutableArray array];
        _world = [[SKPhysicsWorld alloc] init];
        _world.contactDelegate = self;
        _world.gravity = CGPointZero;
        _map = [TankLevelMap new];
	}
	return self;
}

- (NSDictionary*)rep
{
    return WorldDictAppend([super rep], @{
        @"levelNumber": @(self.levelNumber),
		@"map": self.map.identifier ?: [NSNull null],
	});
}
- (void)updateFromRep:(NSDictionary*)rep fetcher:(WorldEntityFetcher)fetcher
{
    [super updateFromRep:rep fetcher:fetcher];
    WorldIf(rep, @"levelNumber", ^(id o) { self.levelNumber = [o intValue]; });
    WorldIf(rep, @"map", ^(id o) {
		self.map = [o isEqual:[NSNull null]] ? nil : fetcher(o, [TankLevelMap class], NO);
    });
}



- (NSArray*)physicalEntities
{
    return [[self.tanks arrayByAddingObjectsFromArray:self.bullets] arrayByAddingObjectsFromArray:self.mines];
}
+ (NSSet*)keyPathsForValuesAffectingPhysicalEntities
{
    return [NSSet setWithArray:@[@"tanks", @"bullets", @"mines"]];
}

- (void)tick:(float)delta inGame:(TankGame*)game;
{
	for(TankPhysicalEntity *ent in self.physicalEntities)
        [ent applyForces];
    
    [_world stepWithTime:delta velocityIterations:10 positionIterations:10];
	
	for(TankPhysicalEntity *ent in self.physicalEntities)
        [ent updatePropertiesFromPhysics];
  
  // Update enemies!!
  for (TankEnemyTank *enemyTank in self.enemyTanks) {
	  [enemyTank update:delta game:game];
  }
    
    for(TankMine *mine in [self.mines copy]) {
        [mine update:delta game:game];
    }
}

- (void)startWithPlayers:(NSArray*)players
{
    // Add tanks for players in the level
    for(TankPlayer *player in players) {
        player.tank = [TankTank new];
        [player.tank updatePhysicsFromProperties];
        [[self mutableArrayValueForKey:@"tanks"] addObject:player.tank];
    }

    [self.map addWallsToPhysics:self.world];
}

#pragma mark physics
- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *a = contact.bodyA;
    WorldEntity *ae = SKPhysicsBodyGetUserData(a);
    SKPhysicsBody *b = contact.bodyB;
    WorldEntity *be = SKPhysicsBodyGetUserData(b);
    
    if([ae respondsToSelector:@selector(collided:withBody:entity:inGame:)])
        [(id)ae collided:contact withBody:b entity:be inGame:self.parent];
    if([be respondsToSelector:@selector(collided:withBody:entity:inGame:)])
        [(id)be collided:contact withBody:a entity:ae inGame:self.parent];
}

- (void)didEndContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *a = contact.bodyA;
    WorldEntity *ae = SKPhysicsBodyGetUserData(a);
    SKPhysicsBody *b = contact.bodyB;
    WorldEntity *be = SKPhysicsBodyGetUserData(b);
    
    if([ae respondsToSelector:@selector(endedColliding:withBody:entity:inGame:)])
        [(id)ae endedColliding:contact withBody:b entity:be inGame:self.parent];
    if([be respondsToSelector:@selector(endedColliding:withBody:entity:inGame:)])
        [(id)be endedColliding:contact withBody:a entity:ae inGame:self.parent];
}

@end

@implementation TankLevelServer
- (void)awakeFromPublish
{
	for(int i = 0; i < 2; i++) {
        TankEnemyTank *enemyTank = [[TankEnemyTank alloc] init];
        enemyTank.position = [Vector2 vectorWithX:300+(100*(i+1)) y:200+100*(i+1)];
        [enemyTank updatePhysicsFromProperties];

		[[self mutableArrayValueForKey:@"tanks"] addObject:enemyTank];
        [[self mutableArrayValueForKey:@"enemyTanks"] addObject:enemyTank];
	}
    
    [self sp_addObserver:self forKeyPath:@"physicalEntities" options:NSKeyValueObservingOptionOld selector:@selector(setupPhysicsBodiesWithChange:)];
    [super awakeFromPublish];
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

@end

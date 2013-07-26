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
#import "TankStartLocation.h"

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

+ (NSString*)levelPathForLevel:(int)levelNumber
{
    return [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"level_%d", levelNumber] ofType:@"json"];
}

+ (BOOL)isLastLevel:(int)levelNumber
{
    return [self levelPathForLevel:levelNumber+1] == nil;
}

- (id)initWithLevel:(int)levelNumber
{
    if(self = [self init]) {
        _levelNumber = levelNumber;
        
        NSString *levelPath = [[self class] levelPathForLevel:levelNumber];
        NSError *err;
        id levelJSON = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:levelPath] options:0 error:&err];
        if(!levelJSON) {
            NSLog(@"Failed to read level JSON: %@", levelPath);
        }
        [self loadLevelFromJSON:levelJSON];
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

- (void)loadLevelFromJSON:(NSDictionary*)json
{
    NSAssert([json[@"tilewidth"] intValue] == 30, @"Wrong tileheight");
    NSAssert([json[@"tileheight"] intValue] == 30, @"Wrong tileheight");
    NSAssert([json[@"width"] intValue] == arenaWidth, @"Wrong width");
    NSAssert([json[@"height"] intValue] == arenaHeight, @"Wrong height");
    
    NSArray *tileLayer = json[@"layers"][0][@"data"];
    NSMutableArray *reversedTileLayer = [NSMutableArray arrayWithCapacity:tileLayer.count];
    for(int y = 1; y < arenaHeight+1; y++) {
        for(int x = 0; x < arenaWidth; x++) {
            [reversedTileLayer addObject:tileLayer[(arenaHeight-y)*arenaWidth + x]];
        }
    }
    self.map.map = reversedTileLayer;
    
    for(NSDictionary *object in json[@"layers"][1][@"objects"]) {
        Class klass = NSClassFromString(object[@"type"]);
        WorldEntity *entity = [klass new];
        if([entity respondsToSelector:@selector(setPosition:)]) {
            MutableVector2 *pos = [MutableVector2 vectorWithX:[object[@"x"] floatValue] y:[object[@"y"] floatValue]];
            pos.y = ArenaSizeInPixels.height - pos.y;
            [(TankPhysicalEntity*)entity setPosition:pos];
        }
        for(id key in object[@"properties"])
            [entity setValue:object[@"properties"][key] forKey:key];
        
        if([entity respondsToSelector:@selector(updatePhysicsFromProperties)])
            [(TankPhysicalEntity*)entity updatePhysicsFromProperties];
        
        if([entity isKindOfClass:[TankEnemyTank class]]) {
            [[self mutableArrayValueForKey:@"tanks"] addObject:entity];
            [[self mutableArrayValueForKey:@"enemyTanks"] addObject:entity];
        } else if([entity isKindOfClass:[TankStartLocation class]]) {
            [[self mutableArrayValueForKey:@"startLocations"] addObject:entity];
        } else {
            NSAssert(NO, @"Sorry, don't know what to do with an %@ entity.", klass);
        }
    }
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
        [ent applyForces:delta];
    
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
        player.tank.position = [(TankStartLocation*)self.startLocations[[players indexOfObject:player] % self.startLocations.count] position];
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

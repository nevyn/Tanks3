#import <WorldKit/Shared/Shared.h>
#import <SpriteKit/SpriteKit.h>
#import "TankLevelMap.h"
@class TankGame;

@interface TankLevel : WorldEntity
@property(nonatomic,WORLD_WRITABLE) int levelNumber;
@property(nonatomic,readonly) WORLD_ARRAY *bullets;
@property(nonatomic,readonly) WORLD_ARRAY *tanks;
@property(nonatomic,readonly) WORLD_ARRAY *mines;
@property(nonatomic,readonly) WORLD_ARRAY *enemyTanks;
@property(nonatomic,WORLD_WRITABLE) TankLevelMap *map;

@property(nonatomic,strong) SKPhysicsWorld *world;

- (void)startWithPlayers:(NSArray*)players;

- (void)tick:(float)delta inGame:(TankGame*)game;
@end

#import <WorldKit/Shared/Shared.h>
#import <SpriteKit/SpriteKit.h>

// Tilemap size in tiles
const static int arenaWidth = 22;
const static int arenaHeight = 16;

@interface TankLevel : WorldEntity
@property(nonatomic,readonly) WORLD_ARRAY *bullets;
@property(nonatomic,readonly) WORLD_ARRAY *tanks;
@property(nonatomic,readonly) WORLD_ARRAY *mines;
@property(nonatomic,WORLD_WRITABLE) CGSize levelSize;

// Ints (NSInteger). Remember that the first tile is the LOWER LEFT tile.
@property(nonatomic,WORLD_WRITABLE) WORLD_ARRAY *map;

- (void)addWallsToPhysics:(SKPhysicsWorld*)world;
@end

#import <WorldKit/Shared/Shared.h>

// Tilemap size in tiles
#define WIDTH = 22;
#define HEIGHT = 16;

@interface TankLevel : WorldEntity
@property(nonatomic,readonly) WORLD_ARRAY *bullets;
@property(nonatomic,readonly) WORLD_ARRAY *walls; // BNZLines
@property(nonatomic,WORLD_WRITABLE) CGSize levelSize;
@property(nonatomic,WORLD_WRITABLE) WORLD_ARRAY *map;   // Ints
@end

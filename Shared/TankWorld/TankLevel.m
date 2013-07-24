#define WORLD_WRITABLE_MODEL 1
#import "TankLevel.h"
#import "BNZLine.h"

@implementation TankLevel
- (id)init
{
	if(self = [super init]) {
		_bullets = [NSMutableArray new];
		float w = 800, h = 600;
		_levelSize = CGSizeMake(w, h);
		_walls = [@[
			[BNZLine lineAt:[Vector2 vectorWithX:0 y:0] to:[Vector2 vectorWithX:w y:0]],
			[BNZLine lineAt:[Vector2 vectorWithX:w y:0] to:[Vector2 vectorWithX:w y:h]],
			[BNZLine lineAt:[Vector2 vectorWithX:w y:h] to:[Vector2 vectorWithX:0 y:h]],
			[BNZLine lineAt:[Vector2 vectorWithX:0 y:h] to:[Vector2 vectorWithX:0 y:0]],
		] mutableCopy];
        
        // Original maps are 22 x 16 tiles, so ours are too!
        _map = [@[
            @1, @1, @1, @1, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @1,
            @1, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @2,
            @1, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @1, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @2,
            @0, @0, @0, @0, @1, @2, @1, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,

            @2, @1, @0, @1, @0, @1, @0, @1, @0, @1, @0, @1, @0, @1, @0, @1, @0, @1, @0, @1, @1, @2,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @2,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @2,

            @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @2,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @2,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @1, @2, @1, @0, @2,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @2,
            
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @2, @2, @2, @2, @2
        ] mutableCopy];
	}
	return self;
}

+ (NSSet*)observableToManyAttributes
{
    NSMutableSet *s = [[super observableToManyAttributes] mutableCopy];
    [s removeObject:@"map"];
    [s removeObject:@"walls"];
    return s;
}
@end

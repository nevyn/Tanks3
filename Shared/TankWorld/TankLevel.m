#define WORLD_WRITABLE_MODEL 1
#import "TankLevel.h"
#import "BNZLine.h"

@implementation TankLevel
- (id)init
{
	if(self = [super init]) {
		_bullets = [NSMutableArray new];
		float w = 1024, h = 768;
		_levelSize = CGSizeMake(w, h);
		_walls = [@[
			[BNZLine lineAt:[Vector2 vectorWithX:0 y:0] to:[Vector2 vectorWithX:w y:0]],
			[BNZLine lineAt:[Vector2 vectorWithX:w y:0] to:[Vector2 vectorWithX:w y:h]],
			[BNZLine lineAt:[Vector2 vectorWithX:w y:h] to:[Vector2 vectorWithX:0 y:h]],
			[BNZLine lineAt:[Vector2 vectorWithX:0 y:h] to:[Vector2 vectorWithX:0 y:0]],
		] mutableCopy];
	}
	return self;
}
@end
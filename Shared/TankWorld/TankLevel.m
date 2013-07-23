#define WORLD_WRITABLE_MODEL 1
#import "TankLevel.h"

@implementation TankLevel
- (id)init
{
	if(self = [super init]) {
		_bullets = [NSMutableArray new];
	}
	return self;
}
@end

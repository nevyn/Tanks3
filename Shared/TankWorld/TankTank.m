#define WORLD_WRITABLE_MODEL 1
#import "TankTank.h"

@implementation TankTank
- (id)init
{
	if(self = [super init]) {
		_position = [Vector2 zero];
		_velocity = [Vector2 zero];
		_acceleration  = [Vector2 zero];

	}
	return self;
}
@end

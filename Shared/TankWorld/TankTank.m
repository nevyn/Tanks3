#define WORLD_WRITABLE_MODEL 1
#import "TankTank.h"
#import "BNZLine.h"

@implementation TankTank
- (id)init
{
	if(self = [super init]) {
		_position = [Vector2 zero];
		_velocity = [Vector2 zero];
		_acceleration  = [Vector2 zero];
		_aimingAt = [Vector2 zero];

	}
	return self;
}
- (float)turretRotation
{
	return [[[[BNZLine alloc] initAt:_position to:_aimingAt] vector] angle] - _rotation - M_PI_2;
}
@end

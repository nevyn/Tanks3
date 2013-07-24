#define WORLD_WRITABLE_MODEL 1
#import "TankTank.h"
#import "BNZLine.h"

@implementation TankTank
- (id)init
{
	if(self = [super init]) {
		_position = [Vector2 vectorWithX:10 y:10];
		_velocity = [Vector2 zero];
		_acceleration  = [Vector2 zero];
		_aimingAt = [Vector2 zero];

	}
	return self;
}

- (NSDictionary*)rep
{
    return WorldDictAppend([super rep], @{
        @"position": _position.rep,
		@"velocity": _velocity.rep,
		@"acceleration": _acceleration.rep,
		@"rotation": @(_rotation),
		@"angularVelocity": @(_angularVelocity),
		@"angularAcceleration": @(_angularAcceleration),
		@"aimingAt": _aimingAt.rep,
    });
}
- (void)updateFromRep:(NSDictionary*)rep fetcher:(WorldEntityFetcher)fetcher
{
    [super updateFromRep:rep fetcher:fetcher];
    WorldIf(rep, @"position", ^(id o) { self.position = [[Vector2 alloc] initWithRep:o]; });
    WorldIf(rep, @"velocity", ^(id o) { self.velocity = [[Vector2 alloc] initWithRep:o]; });
    WorldIf(rep, @"acceleration", ^(id o) { self.acceleration = [[Vector2 alloc] initWithRep:o]; });
    WorldIf(rep, @"rotation", ^(id o) { self.rotation = [o floatValue]; });
    WorldIf(rep, @"angularVelocity", ^(id o) { self.angularVelocity = [o floatValue]; });
    WorldIf(rep, @"angularAcceleration", ^(id o) { self.angularAcceleration = [o floatValue]; });
    WorldIf(rep, @"aimingAt", ^(id o) { self.aimingAt = [[Vector2 alloc] initWithRep:o]; });
}

- (float)turretRotation
{
	return [[[[BNZLine alloc] initAt:_position to:_aimingAt] vector] angle] - _rotation - M_PI_2;
}
@end

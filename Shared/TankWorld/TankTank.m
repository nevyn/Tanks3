#define WORLD_WRITABLE_MODEL 1
#import "TankTank.h"
#import "BNZLine.h"

@implementation TankTank
- (id)init
{
	if(self = [super init]) {
		self.position = [Vector2 vectorWithX:10 y:10];
		_aimingAt = [Vector2 zero];
        self.physicsBody = [PKPhysicsBody bodyWithCircleOfRadius:25];
        self.physicsBody.friction = 100;
        self.physicsBody.linearDamping = 10;
        self.physicsBody.angularDamping = 50;
	}
	return self;
}

- (NSDictionary*)rep
{
    return WorldDictAppend([super rep], @{
		@"aimingAt": _aimingAt.rep,
    });
}
- (void)updateFromRep:(NSDictionary*)rep fetcher:(WorldEntityFetcher)fetcher
{
    [super updateFromRep:rep fetcher:fetcher];
    WorldIf(rep, @"aimingAt", ^(id o) { self.aimingAt = [[Vector2 alloc] initWithRep:o]; });
}

- (float)turretRotation
{
	return [[[[BNZLine alloc] initAt:self.position to:_aimingAt] vector] angle] - self.rotation - M_PI_2;
}
@end

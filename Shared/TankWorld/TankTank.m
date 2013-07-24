#define WORLD_WRITABLE_MODEL 1
#import "TankTank.h"
#import "BNZLine.h"

@implementation TankTank
- (id)init
{
	if(self = [super init]) {
		self.position = [Vector2 vectorWithX:10 y:10];
        self.moveIntent = [Vector2 vectorWithX:0 y:0];
        
        self.speed = 60;
		
        _aimingAt = [Vector2 zero];
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:25];
//        self.physicsBody.friction = 100;
//        self.physicsBody.linearDamping = 0.0;
        self.physicsBody.angularDamping = 50;
	}
	return self;
}

- (NSDictionary*)rep
{
    return WorldDictAppend([super rep], @{
//        @"moveIntent": _moveIntent.rep,
		@"aimingAt": _aimingAt.rep,
    });
}
- (void)updateFromRep:(NSDictionary*)rep fetcher:(WorldEntityFetcher)fetcher
{
    [super updateFromRep:rep fetcher:fetcher];
//    WorldIf(rep, @"moveIntent", ^(id o) { self.moveIntent = [[Vector2 alloc] initWithRep:o]; });
    WorldIf(rep, @"aimingAt", ^(id o) { self.aimingAt = [[Vector2 alloc] initWithRep:o]; });
}

- (float)turretRotation
{
	return [[[[BNZLine alloc] initAt:self.position to:_aimingAt] vector] angle] - self.rotation - M_PI_2;
}

-(void)applyForces; {
    if(self.canMove) {
        //self.acceleration = [self.moveIntent vectorByMultiplyingWithScalar:tankMaxSpeed];
        self.physicsBody.velocity = [[[self moveIntent] vectorByMultiplyingWithScalar:self.speed] point];
    } else {
        //self.acceleration = [Vector2 vector];
        self.physicsBody.velocity = CGPointMake(0, 0);
        
        if([self.moveIntent length]) {
            self.angularAcceleration = tankRotationSpeed;
        } else {
            self.angularAcceleration = 0;
        }
    }
    [super applyForces];
}
@end

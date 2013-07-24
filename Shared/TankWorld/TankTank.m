#define WORLD_WRITABLE_MODEL 1
#import "TankTank.h"
#import "BNZLine.h"
#import "SKPhysics+Private.h"

@implementation TankTank
- (id)init
{
	if(self = [super init]) {
		self.position = [Vector2 vectorWithX:10 y:10];
        self.moveIntent = [Vector2 vectorWithX:0 y:0];
        
        self.speed = 60;
		
        _aimingAt = [Vector2 zero];
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:20];
//        self.physicsBody.friction = 100;
//        self.physicsBody.linearDamping = 0.0;
        self.physicsBody.angularDamping = 30;
        self.physicsBody.allowsRotation = NO;
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

-(void)applyForces
{
    if(![self.moveIntent length]) {
        self.physicsBody.velocity = CGPointZero;
        self.physicsBody.angularVelocity = 0;
        return [super applyForces];
    }

    if(!self.canMove) {
        // Rotate
        
        // Rotate towards the intended direction
        Vector2 *look = [[Vector2 vectorWithX:0 y:1] vectorByRotatingByRadians:self.rotation];
        
        // Goals are relative to look dir!
        
        // Angle to move intent, from up
        float goal1 = [look angleTo:self.moveIntent];
        
        // Angle to inversed move intent, from up
        float goal2 = [look angleTo:[self.moveIntent invertedVector]];
        
        float goal = fabsf(goal1) < fabsf(goal2) ? goal1 : goal2;
        
        
        self.physicsBody.velocity = CGPointZero;
        self.physicsBody.angularVelocity = tankRotationSpeed * (goal < 0 ? -1 : 1);
        
        if(goal > -0.1 && goal < 0.1) {
            self.physicsBody.rotation += goal;
            self.physicsBody.angularVelocity = 0;
            self.canMove = YES;
        }
    }
    
    if(self.canMove) {
        self.physicsBody.velocity = [[[self moveIntent] vectorByMultiplyingWithScalar:self.speed] point];
    }
}
@end

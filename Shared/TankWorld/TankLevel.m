#define WORLD_WRITABLE_MODEL 1
#import "TankLevel.h"
#import "BNZLine.h"

@implementation TankLevel
- (id)init
{
	if(self = [super init]) {
		_bullets = [NSMutableArray new];
		float w = 660, h = 480;
		_levelSize = CGSizeMake(w, h);
        
        // Original maps are 22 x 16 tiles, so ours are too!
        _map = [@[
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @1, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @1, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @2, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @2, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,

            @0, @0, @0, @0, @0, @0, @0, @0, @0, @1, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @1, @0, @0, @0, @0, @1, @1, @0, @0, @0, @0, @0, @1, @1, @0, @0, @0, @0, @0, @0, @0, @1,
            @0, @0, @0, @0, @0, @1, @1, @0, @0, @0, @0, @0, @1, @1, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,

            @0, @0, @0, @0, @0, @0, @0, @0, @0, @1, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @2, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @2, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @1, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,
            
            @0, @0, @0, @0, @0, @0, @0, @0, @0, @1, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0
        ] mutableCopy];
	}
	return self;
}

- (void)addWallsToPhysics:(PKPhysicsWorld*)world
{
    CGPathRef path = CGPathCreateWithRect((CGRect){.size=self.levelSize}, NULL);
    PKPhysicsBody *body = [PKPhysicsBody bodyWithEdgeLoopFromPath:path];
    CGPathRelease(path);
    [world addBody:body];
}

+ (NSSet*)observableToManyAttributes
{
    NSMutableSet *s = [[super observableToManyAttributes] mutableCopy];
    [s removeObject:@"map"];
    [s removeObject:@"walls"];
    return s;
}
@end

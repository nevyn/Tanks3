#define WORLD_WRITABLE_MODEL 1
#import "TankBullet.h"

@implementation TankBullet
- (id)init
{
    if(self = [super init]) {
        self.physicsBody = [PKPhysicsBody bodyWithCircleOfRadius:2];
        self.physicsBody.angularDamping = 100000;
    }
    return self;
}

- (NSDictionary*)rep
{
    return WorldDictAppend([super rep], @{
		@"speed": @(_speed),
		@"collisionTTL": @(_collisionTTL),
    });
}
- (void)updateFromRep:(NSDictionary*)rep fetcher:(WorldEntityFetcher)fetcher
{
    [super updateFromRep:rep fetcher:fetcher];
    WorldIf(rep, @"speed", ^(id o) { self.speed = [o floatValue]; });
    WorldIf(rep, @"collisionTTL", ^(id o) { self.collisionTTL = [o intValue]; });
}

- (void)applyForces;
{
    self.acceleration = [[[Vector2 vectorWithX:0 y:1] vectorByRotatingByRadians:self.rotation] vectorByMultiplyingWithScalar:self.speed];
    [super applyForces];
}

@end

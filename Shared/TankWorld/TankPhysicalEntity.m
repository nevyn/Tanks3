#define WORLD_WRITABLE_MODEL 1
#import "TankPhysicalEntity.h"
#import "SKPhysics+Private.h"

@implementation TankPhysicalEntity
- (id)init
{
    if(self = [super init]) {
        self.position = [Vector2 zero];
        self.velocity = [Vector2 zero];
        self.acceleration = [Vector2 zero];
        self.speed = 0.0f;
    }
    return self;
}

- (NSDictionary*)rep
{
    return WorldDictAppend([super rep], @{
        @"position": _position.rep,
        @"velocity": _velocity.rep,
        @"acceleration": _acceleration.rep,
        @"speed": @(_speed),
		@"rotation": @(_rotation),
		@"angularAcceleration": @(_angularAcceleration),
    });
}
- (void)updateFromRep:(NSDictionary*)rep fetcher:(WorldEntityFetcher)fetcher
{
    [super updateFromRep:rep fetcher:fetcher];
    WorldIf(rep, @"position", ^(id o) { self.position = [[Vector2 alloc] initWithRep:o]; });
    WorldIf(rep, @"velocity", ^(id o) { self.velocity = [[Vector2 alloc] initWithRep:o]; });
    WorldIf(rep, @"acceleration", ^(id o) { self.acceleration = [[Vector2 alloc] initWithRep:o]; });
    WorldIf(rep, @"speed", ^(id o) { self.speed = [o floatValue]; });
    WorldIf(rep, @"rotation", ^(id o) { self.rotation = [o floatValue]; });
    WorldIf(rep, @"angularAcceleration", ^(id o) { self.angularAcceleration = [o floatValue]; });
}

- (void)updatePropertiesFromPhysics
{
    self.position = [Vector2 vectorWithPoint:self.physicsBody.position];
    self.velocity = [Vector2 vectorWithPoint:self.physicsBody.velocity];
    self.rotation = self.physicsBody.rotation;
}

- (void)updatePhysicsFromProperties
{
    self.physicsBody.position = self.position.point;
    self.physicsBody.rotation = self.rotation;
}

- (void)applyForces
{
    [self.physicsBody applyForce:[self acceleration].point];
    [self.physicsBody applyTorque:[self angularAcceleration]];
    
    // Don't go over max speed
    Vector2 *vel = [Vector2 vectorWithPoint:self.physicsBody.velocity];
    if([vel length] > self.speed) {
        self.physicsBody.velocity = [[[vel normalizedVector] vectorByMultiplyingWithScalar:self.speed] point];
    }
}

- (void)collided:(SKPhysicsContact*)contact withBody:(SKPhysicsBody*)body entity:(WorldEntity*)other inGame:(TankGame *)game {}
- (void)endedColliding:(SKPhysicsContact*)contact withBody:(SKPhysicsBody*)body entity:(WorldEntity*)other inGame:(TankGame *)game {}
@end

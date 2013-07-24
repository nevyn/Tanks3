#define WORLD_WRITABLE_MODEL 1
#import "TankPhysicalEntity.h"

@interface SKPhysicsBody (Private)
@property(nonatomic) CGPoint position;
@property(nonatomic) double rotation;
@end

@implementation TankPhysicalEntity
- (id)init
{
    if(self = [super init]) {
        self.position = [Vector2 zero];
        self.acceleration = [Vector2 zero];
    }
    return self;
}

- (NSDictionary*)rep
{
    return WorldDictAppend([super rep], @{
        @"position": _position.rep,
        @"acceleration": _acceleration.rep,
		@"rotation": @(_rotation),
		@"angularAcceleration": @(_angularAcceleration),
    });
}
- (void)updateFromRep:(NSDictionary*)rep fetcher:(WorldEntityFetcher)fetcher
{
    [super updateFromRep:rep fetcher:fetcher];
    WorldIf(rep, @"position", ^(id o) { self.position = [[Vector2 alloc] initWithRep:o]; });
    WorldIf(rep, @"acceleration", ^(id o) { self.acceleration = [[Vector2 alloc] initWithRep:o]; });
    WorldIf(rep, @"rotation", ^(id o) { self.rotation = [o floatValue]; });
    WorldIf(rep, @"angularAcceleration", ^(id o) { self.angularAcceleration = [o floatValue]; });
}

- (void)updatePropertiesFromPhysics
{
    self.position = [Vector2 vectorWithPoint:self.physicsBody.position];
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
}

@end

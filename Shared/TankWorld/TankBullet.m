#define WORLD_WRITABLE_MODEL 1
#import "TankBullet.h"

@implementation TankBullet
- (NSDictionary*)rep
{
    return WorldDictAppend([super rep], @{
        @"position": _position.rep,
		@"angle": @(_angle),
		@"speed": @(_speed),
		@"collisionTTL": @(_collisionTTL),
    });
}
- (void)updateFromRep:(NSDictionary*)rep fetcher:(WorldEntityFetcher)fetcher
{
    [super updateFromRep:rep fetcher:fetcher];
    WorldIf(rep, @"position", ^(id o) { self.position = [[Vector2 alloc] initWithRep:o]; });
    WorldIf(rep, @"angle", ^(id o) { self.angle = [o floatValue]; });
    WorldIf(rep, @"speed", ^(id o) { self.speed = [o floatValue]; });
    WorldIf(rep, @"collisionTTL", ^(id o) { self.collisionTTL = [o intValue]; });
}

@end

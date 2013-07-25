#define WORLD_WRITABLE_MODEL 1
#import "TankStartLocation.h"

@implementation TankStartLocation
- (NSDictionary*)rep
{
    return WorldDictAppend([super rep], @{
        @"position": self.position.rep,
	});
}
- (void)updateFromRep:(NSDictionary*)rep fetcher:(WorldEntityFetcher)fetcher
{
    [super updateFromRep:rep fetcher:fetcher];
    WorldIf(rep, @"position", ^(id o) { self.position = [[Vector2 alloc] initWithRep:o]; });
}
@end

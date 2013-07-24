#define WORLD_WRITABLE_MODEL 1
#import "TankPlayer.h"
#import "TankTank.h"

#define MOVE_SPEED = 100;
#define ROTATE_SPEED = M_PI;

@implementation TankPlayer
- (NSDictionary*)rep
{
    return WorldDictAppend([super rep], @{
		@"tank": self.tank.identifier ?: [NSNull null],
	});
}
- (void)updateFromRep:(NSDictionary*)rep fetcher:(WorldEntityFetcher)fetcher
{
    [super updateFromRep:rep fetcher:fetcher];
    WorldIf(rep, @"tank", ^(id o) {
		self.tank = [o isEqual:[NSNull null]] ? nil : fetcher(o, [TankTank class], NO);
    });
}

@end

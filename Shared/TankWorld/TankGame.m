#define WORLD_WRITABLE_MODEL 1
#import <SPSuccinct/SPSuccinct.h>
#import "TankGame.h"
#import "TankPlayer.h"
#import "TankTank.h"

@implementation TankGame
- (void)tick:(float)delta
{

}
@end

@implementation TankGameServer
- (void)awakeFromPublish
{
	[super awakeFromPublish];
    
	[self sp_addObserver:self forKeyPath:@"players" options:NSKeyValueObservingOptionInitial callback:^(NSDictionary *change, id object, NSString *keyPath) {
		for(TankPlayer *player in [object players]) {
			if (!player.tank)
				player.tank = [TankTank new];
		}
	}];
}
@end

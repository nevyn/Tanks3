#import <WorldKit/Shared/Shared.h>
@class TankLevel;
static const int kTankServerPort = 29534;

@interface TankGame : WorldGame
@property(WORLD_WRITABLE) TankLevel *currentLevel;

- (void)tick:(float)delta;
@end

@interface TankGameServer : TankGame
@end

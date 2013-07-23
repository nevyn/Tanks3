#import <WorldKit/Shared/Shared.h>
@class TankLevel;
static const int kTankServerPort = 29534;

@interface TankGame : WorldGame
@property(nonatomic,WORLD_WRITABLE) TankLevel *currentLevel;
@property(nonatomic,readonly) WORLD_ARRAY *enemyTanks;

- (void)tick:(float)delta;
@end

@interface TankGameServer : TankGame
@end

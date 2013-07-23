#import <WorldKit/Shared/Shared.h>
@class TankTank;

@interface TankPlayer : WorldGamePlayer
@property(WORLD_WRITABLE) TankTank *tank;
@end

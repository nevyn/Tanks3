#import <Foundation/Foundation.h>

@class TankTank;

@interface TankTankController : NSObject
- (void)tickWithTank:(TankTank *)tank delta:(float)delta;
@end

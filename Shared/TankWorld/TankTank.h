#import <WorldKit/Shared/Shared.h>
#import "TankPhysicalEntity.h"

@interface TankTank : TankPhysicalEntity
@property(nonatomic,WORLD_WRITABLE) Vector2 *aimingAt;
- (float)turretRotation;
@end

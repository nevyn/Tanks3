#import <WorldKit/Shared/Shared.h>
#import "TankPhysicalEntity.h"

// Pixels per second
const static float tankMaxSpeed = 60;

// Radians per second
const static float tankRotationSpeed = M_PI*2;


@interface TankTank : TankPhysicalEntity
@property(nonatomic,WORLD_WRITABLE) Vector2 *aimingAt;

// This is where the tanks wants to go.
// Speed modifier, between 0 and 1.
@property(nonatomic,WORLD_WRITABLE) Vector2 *moveIntent;
@property(nonatomic) BOOL canMove;  // YES when facing same direction as velocity

- (float)turretRotation;
@end

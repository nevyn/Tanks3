#import <WorldKit/Shared/Shared.h>

// Pixels per second
const static float tankMaxSpeed = 60;

// Radians per second
const static float tankRotationSpeed = M_PI;

@interface TankTank : WorldEntity

@property(nonatomic,WORLD_WRITABLE) Vector2 *position;

// This is where the tanks wants to go.
// Speed modifier, between 0 and 1.
@property(nonatomic,WORLD_WRITABLE) Vector2 *moveIntent;

// 0 is up, cw
// The tank only has 180 degrees, essentially.
@property(nonatomic,WORLD_WRITABLE) float rotation;

@property(nonatomic) BOOL canMove;  // YES when facing same direction as velocity


//@property(nonatomic,WORLD_WRITABLE) Vector2 *acceleration;
//@property(nonatomic,WORLD_WRITABLE) float angularVelocity;
//@property(nonatomic,WORLD_WRITABLE) float angularAcceleration;

@property(nonatomic,WORLD_WRITABLE) Vector2 *aimingAt;
- (float)turretRotation;
@end

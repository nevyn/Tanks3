#import <WorldKit/Shared/Shared.h>
#import "TankPhysicalEntity.h"
@class TankLevel;

// Pixels per second
const static float TankMaxSpeed = 60;

const static float TankCollisionRadius = 12;

// Radians per second
const static float TankRotationSpeed = M_PI*2;


@interface TankTank : TankPhysicalEntity
@property(nonatomic,WORLD_WRITABLE) Vector2 *aimingAt;

// This is where the tanks wants to go.
// Speed modifier, between 0 and 1.
@property(nonatomic,WORLD_WRITABLE) Vector2 *moveIntent;
@property(nonatomic) BOOL canMove;  // YES when facing same direction as velocity

- (float)turretRotation;
- (void)fireBulletIntoLevel:(TankLevel*)level;
- (void)layMineIntoLevel:(TankLevel*)level;
@end

#import <WorldKit/Shared/Shared.h>
#import "TankPhysicalEntity.h"
@class TankLevel;
@class TankBullet, TankMine;

// Pixels per second
const static float TankMaxSpeed = 60;

const static float TankCollisionRadius = 12;

// Radians per second
const static float TankRotationSpeed = M_PI*2;

const static float TankFiringMovementPenaltyDuration = 0.2;


@interface TankTank : TankPhysicalEntity
@property(nonatomic,WORLD_WRITABLE) Vector2 *aimingAt;

// This is where the tanks wants to go.
// Speed modifier, between 0 and 1.
@property(nonatomic,WORLD_WRITABLE) Vector2 *moveIntent;
@property(nonatomic,WORLD_WRITABLE) BOOL canMove;  // YES when facing same direction as velocity
@property(nonatomic,WORLD_WRITABLE) NSTimeInterval movementPenalty; // can't move for this long because tank just fired

- (float)turretRotation;
- (TankBullet*)fireBulletIntoLevel:(TankLevel*)level;
- (TankMine*)layMineIntoLevel:(TankLevel*)level;
@end

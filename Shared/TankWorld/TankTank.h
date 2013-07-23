#import <WorldKit/Shared/Shared.h>

@interface TankTank : WorldEntity
@property(nonatomic,WORLD_WRITABLE) Vector2 *position;
@property(nonatomic,WORLD_WRITABLE) Vector2 *velocity;
@property(nonatomic,WORLD_WRITABLE) Vector2 *acceleration;
@property(nonatomic,WORLD_WRITABLE) float rotation; // 0 is up, cw
@property(nonatomic,WORLD_WRITABLE) float angularVelocity;
@property(nonatomic,WORLD_WRITABLE) float angularAcceleration;

@property(nonatomic,WORLD_WRITABLE) Vector2 *aimingAt;
- (float)turretRotation;
@end

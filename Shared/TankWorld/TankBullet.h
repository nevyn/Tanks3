#import <WorldKit/Shared/Shared.h>

static const float TankBulletStandardSpeed = 120; // pixels/s

@interface TankBullet : WorldEntity
@property(nonatomic,WORLD_WRITABLE) Vector2 *position;
@property(nonatomic,WORLD_WRITABLE) float angle;
@property(nonatomic,WORLD_WRITABLE) float speed;
@property(nonatomic,WORLD_WRITABLE) int collisionTTL;
@end

#import <WorldKit/Shared/Shared.h>

@interface TankBullet : WorldEntity
@property(nonatomic,WORLD_WRITABLE) Vector2 *position;
@property(nonatomic,WORLD_WRITABLE) float angle;
@property(nonatomic,WORLD_WRITABLE) float speed;
@property(nonatomic,WORLD_WRITABLE) int collisionTTL;
@end

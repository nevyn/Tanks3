#import <WorldKit/Shared/Shared.h>
#import "TankPhysicalEntity.h"

static const float TankBulletStandardSpeed = 200; // pixels/s

@interface TankBullet : TankPhysicalEntity
@property(nonatomic,WORLD_WRITABLE) int collisionTTL;
@property(nonatomic,WORLD_WRITABLE) BOOL enemyBullet; // shot by AI tank?
@end

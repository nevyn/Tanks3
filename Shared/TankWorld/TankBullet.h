#import <WorldKit/Shared/Shared.h>
#import "TankPhysicalEntity.h"

static const float TankBulletStandardSpeed = 100; // pixels/s

@interface TankBullet : TankPhysicalEntity
@property(nonatomic,WORLD_WRITABLE) int collisionTTL;
@end

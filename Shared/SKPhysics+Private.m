#import "SKPhysics+Private.h"
#import <objc/runtime.h>

@implementation SKPhysicsBody (TankUserData)
static const void *const key = &key;
- (id)tank_userdata
{
    return objc_getAssociatedObject(self, key);
}

- (void)setTank_userdata:(id)tank_userdata
{
    objc_setAssociatedObject(self, key, tank_userdata, OBJC_ASSOCIATION_ASSIGN);
}
@end
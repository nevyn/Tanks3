#import "SKPhysics+Private.h"
#import <objc/runtime.h>

@interface PKPhysicsBody : NSObject
@end
@interface PKPhysicsBody (TankUserData)
@property(nonatomic,unsafe_unretained) id tank_userdata;
@end

static const void *const key = &key;
id SKPhysicsBodyGetUserData(SKPhysicsBody *body)
{
    if(!body) return nil;
    return objc_getAssociatedObject(body, key);
}

void SKPhysicsBodySetUserData(SKPhysicsBody *body, id userdata)
{
    if(!body) return;
    objc_setAssociatedObject(body, key, userdata, OBJC_ASSOCIATION_ASSIGN);
}

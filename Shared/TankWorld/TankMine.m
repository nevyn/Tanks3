#define WORLD_WRITABLE_MODEL 1
#import "TankMine.h"
#import "SKPhysics+Private.h"

@implementation TankMine

-(id)init {
    if(self = [super init]) {
        _timer = 2.0f;
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:20];
    }
    return self;
}

@end


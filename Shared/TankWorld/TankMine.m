#define WORLD_WRITABLE_MODEL 1
#import "TankMine.h"
#import "SKPhysics+Private.h"
#import "TankGame.h"

@implementation TankMine

-(id)init {
    if(self = [super init]) {
        _timer = 2.0f;
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:20];
    }
    return self;
}

- (void) update:(float)delta game:(TankGame*)game; {
    _timer -= delta;
    
    if(_timer <= 0.0f) {
        [self removeFromParent];
    }
}

@end


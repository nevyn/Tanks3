#import <SpriteKit/SpriteKit.h>

@interface SKPhysicsWorld (Private)
- (void)removeBody:(id)arg1;
- (void)addBody:(id)arg1;
- (BOOL)stepWithTime:(double)arg1 velocityIterations:(unsigned long long)arg2 positionIterations:(unsigned long long)arg3;
@end

@interface SKPhysicsBody (Private)
@property(nonatomic) id _world;
@property(nonatomic) CGPoint position;
@property(nonatomic) double rotation;
@end

// Can't add categories to SKPhysicsData because it *is* an PKPhysicsData :(
id SKPhysicsBodyGetUserData(SKPhysicsBody *body);
void SKPhysicsBodySetUserData(SKPhysicsBody *body, id userdata);
#import <Foundation/Foundation.h>
@class PKPhysicsBody;

@interface PKPhysicsContact : NSObject
@property(readonly) double collisionImpulse;
@property(readonly) struct CGPoint contactPoint;
@property(readonly) PKPhysicsBody *bodyB;
@property(readonly) PKPhysicsBody *bodyA;
- (void)setCollisionImpulse:(double)arg1;
- (void)setContactPoint:(struct CGPoint)arg1;
@property BOOL didEnd;
@property BOOL didBegin;
- (id)init;

@end


#import <Foundation/Foundation.h>
#import <PhysicsKit/PKPhysicsJoint.h>

@interface PKPhysicsJointDistance : PKPhysicsJoint
+ (id)jointWithBodyA:(id)arg1 bodyB:(id)arg2 anchorA:(struct CGPoint)arg3 anchorB:(struct CGPoint)arg4;
+ (id)jointWithBodyA:(id)arg1 bodyB:(id)arg2 localAnchorA:(struct CGPoint)arg3 localAnchorB:(struct CGPoint)arg4;
@property double frequency;
@property double length;
@property double damping;
- (void)create;
- (id)initWithBodyA:(id)arg1 bodyB:(id)arg2 localAnchorA:(struct CGPoint)arg3 localAnchorB:(struct CGPoint)arg4;
- (id)initWithBodyA:(id)arg1 bodyB:(id)arg2 anchorA:(struct CGPoint)arg3 anchorB:(struct CGPoint)arg4;
@end


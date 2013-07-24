#import <Foundation/Foundation.h>
@class PKPhysicsContact;
@protocol PKPhysicsContactDelegate;

@interface PKPhysicsWorld : NSObject <NSCoding>
+ (id)world;
- (BOOL)stepWithTime:(double)arg1 velocityIterations:(unsigned long long)arg2 positionIterations:(unsigned long long)arg3;
- (void)removeAllJoints;
- (void)removeJoint:(id)arg1;
- (void)addJoint:(id)arg1;
- (void)removeAllBodies;
- (void)removeBody:(id)arg1;
- (void)addBody:(id)arg1;
- (id)bodies;
@property id <PKPhysicsContactDelegate> contactDelegate;
@property struct CGPoint gravity;
- (BOOL)hasBodies;
- (id)init;
@property double speed;
- (id)bodyAlongRayStart:(struct CGPoint)arg1 end:(struct CGPoint)arg2;
- (id)bodyInRect:(struct CGRect)arg1;
- (id)bodyAtPoint:(struct CGPoint)arg1;
- (void)enumerateBodiesAlongRayStart:(struct CGPoint)arg1 end:(struct CGPoint)arg2 usingBlock:(id)arg3;
- (void)enumerateBodiesInRect:(struct CGRect)arg1 usingBlock:(id)arg2;
- (void)enumerateBodiesAtPoint:(struct CGPoint)arg1 usingBlock:(id)arg2;
- (void)_runBlockOutsideOfTimeStep:(id)arg1;
@end

@protocol PKPhysicsContactDelegate <NSObject>
@optional
- (void)didBeginContact:(PKPhysicsContact *)contact;
- (void)didEndContact:(PKPhysicsContact *)contact;
@end
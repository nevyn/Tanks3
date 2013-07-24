#import <Foundation/Foundation.h>

@class NSArray, NSMutableArray, PKPhysicsWorld;

@interface PKPhysicsBody : NSObject <NSCopying, NSCoding>
+ (id)bodyWithEdgeLoopFromPath:(struct CGPath *)arg1;
+ (id)bodyWithEdgeChainFromPath:(struct CGPath *)arg1;
+ (id)bodyWithPolygonFromPath:(struct CGPath *)arg1;
+ (id)bodyWithEdgeFromPoint:(struct CGPoint)arg1 toPoint:(struct CGPoint)arg2;
+ (id)bodyWithRectangleOfSize:(struct CGSize)arg1;
+ (id)bodyWithCircleOfRadius:(double)arg1;
@property(copy) id postStepBlock;
- (id)allContactedBodies;
@property(getter=isDynamic) BOOL dynamic;
@property double friction;
@property double restitution;
@property(readonly) double area;
@property double density;
@property double mass;
@property(readonly) NSArray *joints;
@property(getter=isResting) BOOL resting;
@property BOOL allowsRotation;
@property double angularVelocity;
@property struct CGPoint velocity;
@property unsigned int contactTestBitMask;
@property unsigned int collisionBitMask;
@property unsigned int categoryBitMask;
@property BOOL affectedByGravity;
@property BOOL usesPreciseCollisionDetection;
- (void)applyUnscaledImpulse:(struct CGPoint)arg1;
- (void)applyUnscaledImpulse:(struct CGPoint)arg1 atPoint:(struct CGPoint)arg2;
- (void)applyUnscaledForce:(struct CGPoint)arg1;
- (void)applyUnscaledForce:(struct CGPoint)arg1 atPoint:(struct CGPoint)arg2;
- (void)applyAngularImpulse:(double)arg1;
- (void)applyImpulse:(struct CGPoint)arg1;
- (void)applyImpulse:(struct CGPoint)arg1 atPoint:(struct CGPoint)arg2;
- (void)applyTorque:(double)arg1;
- (void)applyForce:(struct CGPoint)arg1;
- (void)applyForce:(struct CGPoint)arg1 atPoint:(struct CGPoint)arg2;
@property double angularDamping;
@property double linearDamping;
@property double rotation;
- (BOOL)_allowSleep;
- (void)set_allowSleep:(BOOL)arg1;
@property struct CGPoint position;
@property __weak id <NSObject> representedObject;
- (id)initWithEdgeLoopFromPath:(struct CGPath *)arg1;
- (id)initWithEdgeChainFromPath:(struct CGPath *)arg1;
- (id)initWithPolygonFromPath:(struct CGPath *)arg1;
- (id)initWithEdgeFromPoint:(struct CGPoint)arg1 toPoint:(struct CGPoint)arg2;
- (id)initWithRectangleOfSize:(struct CGSize)arg1;
- (id)initWithCircleOfRadius:(double)arg1;
- (id)init;
- (void)setActive:(BOOL)arg1;
- (BOOL)active;
- (BOOL)isSensor;
- (void)setIsSensor:(BOOL)arg1;
- (id)_world;
@end


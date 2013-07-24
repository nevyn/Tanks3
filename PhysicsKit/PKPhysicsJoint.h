#import <Foundation/Foundation.h>
@class PKPhysicsBody;

@interface PKPhysicsJoint : NSObject <NSCoding>
@property(retain) PKPhysicsBody *bodyB;
@property(retain) PKPhysicsBody *bodyA;
- (id)init;
- (void)create;
@end


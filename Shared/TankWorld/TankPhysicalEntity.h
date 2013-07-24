#import <WorldKit/Shared/Shared.h>
#import <SpriteKit/SpriteKit.h>

@interface TankPhysicalEntity : WorldEntity
@property(nonatomic,WORLD_WRITABLE) Vector2 *position;
@property(nonatomic,WORLD_WRITABLE) Vector2 *acceleration;
@property(nonatomic,WORLD_WRITABLE) float rotation; // 0 is up, cw
@property(nonatomic,WORLD_WRITABLE) float angularAcceleration;
@property(nonatomic,WORLD_WRITABLE) SKPhysicsBody *physicsBody;
- (void)updatePropertiesFromPhysics;
- (void)updatePhysicsFromProperties;
- (void)applyForces;
@end

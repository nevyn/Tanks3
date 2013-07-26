#import <WorldKit/Shared/Shared.h>
#import <SpriteKit/SpriteKit.h>
@class TankGame;

@interface TankPhysicalEntity : WorldEntity
@property(nonatomic,WORLD_WRITABLE) Vector2 *position;
@property(nonatomic,WORLD_WRITABLE) Vector2 *velocity;
@property(nonatomic,WORLD_WRITABLE) Vector2 *acceleration;
@property(nonatomic,WORLD_WRITABLE) float speed; // Max speed, pixels per second
@property(nonatomic,WORLD_WRITABLE) float rotation; // 0 is up, cw
@property(nonatomic,WORLD_WRITABLE) float angularAcceleration;
@property(nonatomic,WORLD_WRITABLE) SKPhysicsBody *physicsBody;
- (void)updatePropertiesFromPhysics;
- (void)updatePhysicsFromProperties;
- (void)applyForces:(float)delta;

- (void)collided:(SKPhysicsContact*)contact withBody:(SKPhysicsBody*)body entity:(WorldEntity*)other inGame:(TankGame*)game;
- (void)endedColliding:(SKPhysicsContact*)contact withBody:(SKPhysicsBody*)body entity:(WorldEntity*)other inGame:(TankGame*)game;
@end

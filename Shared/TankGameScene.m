//
//  MVMyScene.m
//  Tanks3
//
//  Created by Joachim Bengtsson on 2013-07-21.
//  Copyright (c) 2013 Mastervone. All rights reserved.
//

#define WORLD_WRITABLE_MODEL 1
#import "TankGameScene.h"
#import "TankPlayer.h"
#import "TankTank.h"
#import "TankEnemyTank.h"
#import "TankLevel.h"
#import "TankBullet.h"
#import <SPSuccinct/SPSuccinct.h>

#import "TankTankController.h"

/* 
 Tank has TankController
 
 TankController solves the movement of the tank.

 */

@interface KeyboardInputTankController : TankTankController
{
    //Setup
    float movementSpeed;
    float rotationSpeed;
    float fireRate;
    
    //State
    float movementRate; //-1 to +1 * movement speed
    float turnRate; //-1 to +1 * rotation speed
    float fireCycle; //0 to 1 of fire cycle done. Can not fire until cycle is complete (is at 1)
}

@property (nonatomic, strong) TankTank *tank;
@property (nonatomic, strong) TankGame *game;

@property (nonatomic, readonly, getter = isMovingForward) BOOL movingForward;
@property (nonatomic, readonly, getter = isMovingbackward) BOOL movingBackward;
@property (nonatomic, readonly, getter = isTurningLeft) BOOL turningLeft;
@property (nonatomic, readonly, getter = isTurningRight) BOOL turningRight;
@property (nonatomic, readonly, getter = isFiring) BOOL firing;

- (void)moveForwardAtRate:(float)percentage;
- (void)moveBackwardAtRate:(float)percentage;
- (void)stopMoving;
- (void)turnLeftAtRate:(float)percentage;
- (void)turnRightAtRate:(float)percentage;
- (void)stopTurning;
- (void)fire;

@end

@implementation KeyboardInputTankController

- (BOOL)isMovingForward
{
    return movementRate > 0;
}

- (void)moveForwardAtRate:(float)percentage
{
    movementRate = +percentage;
}

- (BOOL)isMovingBackward
{
    return movementRate < 0;
}

- (void)moveBackwardAtRate:(float)percentage
{
    movementRate = -percentage;
}

- (void)stopMoving
{
    movementRate = 0;
}

- (BOOL)isTurningLeft
{
    return turnRate < 0;
}

- (void)turnLeftAtRate:(float)percentage
{
    turnRate = -percentage;
}

- (BOOL)isTurningRight
{
    return turnRate > 0;
}

- (void)turnRightAtRate:(float)percentage
{
    turnRate = +percentage;
}

- (void)stopTurning
{
    turnRate = 0;
}

- (BOOL)isFiring
{
    return fireCycle > 0;
}

- (void)fire
{
    fireCycle += 0.1;
}

@end

@interface TankControlsTank : KeyboardInputTankController
@property (nonatomic, strong) TankGame *game;
@end

@implementation TankControlsTank

- (id)init
{
    if (!(self = [super init]))
        return nil;
    
    movementSpeed = 5000;
    rotationSpeed = 80;
    fireRate = 1;
    
    return self;
}

- (void)tickWithTank:(TankTank *)tank delta:(float)delta
{
    tank.acceleration = [[Vector2 vectorWithX:0 y:movementSpeed * movementRate] vectorByRotatingByRadians:tank.rotation];
    tank.angularAcceleration = M_PI * rotationSpeed * -turnRate;
    
//    TankBullet *bullet = [TankBullet new];
//    bullet.speed = 400;
//    [[_game.currentLevel mutableArrayValueForKey:@"bullets"] addObject:bullet];
//    bullet.position = _player.tank.position;
//    bullet.angle = _player.tank.turretRotation + _player.tank.rotation;

    [super tickWithTank:tank delta:delta];
}

@end

@interface PlayerInputState : NSObject
@property (nonatomic, assign) BOOL up;
@property (nonatomic, assign) BOOL down;
@property (nonatomic, assign) BOOL left;
@property (nonatomic, assign) BOOL right;
@property (nonatomic, assign) BOOL fire;
@property (nonatomic, copy) Vector2 *targetPoint;
@end

@implementation PlayerInputState

@end

@interface TankPlayerInputHandler : PlayerInputState
@property (nonatomic, strong) KeyboardInputTankController *tankControls;
@end

void *TankControlFireContext = &TankControlFireContext;

@implementation TankPlayerInputHandler


- (void)update
{
    if (self.up && !self.down && !_tankControls.movingForward)
        [_tankControls moveForwardAtRate:1];
    
    if (self.down && !self.up && !_tankControls.movingBackward)
        [_tankControls moveBackwardAtRate:1];
    
    if (!self.down && !self.up)
        [_tankControls stopMoving];
    
    
    if (self.left && !self.right && !_tankControls.turningLeft)
        [_tankControls turnLeftAtRate:1];
    
    if (self.right && !self.left && !_tankControls.turningRight)
        [_tankControls turnRightAtRate:1];
    
    if (!self.left && !self.right)
        [_tankControls stopTurning];
    
    
    if (self.fire && !_tankControls.firing)
        [_tankControls fire];
}

- (void)setUp:(BOOL)up
{
    [super setUp:up];
    [self update];
}

- (void)setDown:(BOOL)down
{
    [super setDown:down];
    [self update];
}

- (void)setLeft:(BOOL)left
{
    [super setLeft:left];
    [self update];
}

- (void)setRight:(BOOL)right
{
    [super setRight:right];
    [self update];
}

- (void)setFire:(BOOL)fire
{
    [super setFire:fire];
    [self update];
}

@end

@interface TankGameScene ()
@property(nonatomic,readonly) NSMutableDictionary *bulletSprites;
@property(nonatomic,readonly) NSMutableDictionary *tankSprites;
@end

@interface TankNode : SKNode
@property(nonatomic) TankTank *tank;
@property(nonatomic) SKSpriteNode *body;
@property(nonatomic) SKSpriteNode *turret;
@end

@implementation TankNode

- (id)initWithTank:(TankTank*)tank
{
	if(self = [super init]) {
		self.tank = tank;
		
		_body = [SKSpriteNode spriteNodeWithImageNamed:@"Tank"];
		_body.size = CGSizeMake(_body.size.width*0.3, _body.size.height*0.3);
		_turret = [SKSpriteNode spriteNodeWithImageNamed:@"Turret"];
		_turret.size = CGSizeMake(_turret.size.width*0.3, _turret.size.height*0.3);
		_turret.anchorPoint = CGPointMake(0.5, 0.42);
		[_body addChild:_turret];
		[self addChild:_body];
	}
	return self;
}
@end

@implementation TankGameScene
{
	TankGame *_game;
	TankPlayer *_me;

	SKSpriteNode *_meSprite;
	SKSpriteNode *_turretSprite;
    
    TankPlayerInputHandler *_inputHandler;
}

-(id)initWithSize:(CGSize)size game:(TankGame*)clientGame hackyServerGame:(TankGame*)game;
{
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
		_game = game;
		_me = [[TankPlayer alloc] init];
		_me.name = @"Hej";
		_me.identifier = @"Fusk";
		[[game mutableArrayValueForKey:@"players"] addObject:_me];
		
		
		_bulletSprites = [NSMutableDictionary new];
		__weak __typeof(self) weakSelf = self;
		[_game.currentLevel sp_observe:@"bullets" removed:^(id bullet) {
			[weakSelf.bulletSprites[[bullet identifier]] removeFromParent];
			[weakSelf.bulletSprites removeObjectForKey:[bullet identifier]];
		} added:^(id bullet) {
			SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"bulleta"];
			sprite.size = CGSizeMake(sprite.size.width*0.3, sprite.size.height*0.3);
			[weakSelf addChild:sprite];
			weakSelf.bulletSprites[[bullet identifier]] = sprite;
		} initial:YES];
		
		_tankSprites = [NSMutableDictionary new];
		[_game.currentLevel sp_observe:@"tanks" removed:^(id tank) {
			TankNode *node = [weakSelf tankSprites][[tank identifier]];
			[node removeFromParent];
			[weakSelf.tankSprites removeObjectForKey:[tank identifier]];
		} added:^(id tank) {
			TankNode *tankNode = [[TankNode alloc] initWithTank:tank];
			[weakSelf addChild:tankNode];
			[weakSelf tankSprites][[tank identifier]] = tankNode;
		} initial:YES];
        
        
        TankControlsTank *tankControls = [TankControlsTank new];
        tankControls.tank = _me.tank;
        tankControls.game = _game;
        _me.tank.tankController = tankControls;
        
        _inputHandler = [TankPlayerInputHandler new];
        _inputHandler.tankControls = tankControls;
	}
    return self;
}

- (void)didMoveToView:(SKView *)view
{
#if !TARGET_OS_IPHONE
	int opts = (NSTrackingActiveAlways | NSTrackingMouseMoved);
	NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:CGRectMake(0, 0, self.size.width, self.size.height)
                                                 options:opts
                                                   owner:self
                                                userInfo:nil];
	[self.view addTrackingArea:area];
#endif
}

#if TARGET_OS_IPHONE
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}
#else
- (void)mouseMoved:(NSEvent *)theEvent
{
	_me.tank.aimingAt = [Vector2 vectorWithPoint:[theEvent locationInNode:self]];
//    _inputHandler.targetPoint = [Vector2 vectorWithPoint:[theEvent locationInNode:self]];
}
- (void)mouseDown:(NSEvent *)theEvent
{
    // TankBullet *bullet = [TankBullet new];
    // bullet.speed = 1000;
    // bullet.collisionTTL = 2;
    // [[_game.currentLevel mutableArrayValueForKey:@"bullets"] addObject:bullet];
    // bullet.position = _me.tank.position;
    // bullet.angle = _me.tank.turretRotation + _me.tank.rotation;

    _inputHandler.fire = YES;
}

- (void)mouseUp:(NSEvent *)theEvent
{
    _inputHandler.fire = NO;
}

- (void)keyDown:(NSEvent *)theEvent
{
	if([[theEvent characters] isEqual:@"w"])
        _inputHandler.up = YES;
	if([[theEvent characters] isEqual:@"s"])
        _inputHandler.down = YES;
	if([[theEvent characters] isEqual:@"a"])
        _inputHandler.left = YES;
	if([[theEvent characters] isEqual:@"d"])
        _inputHandler.right = YES;
}
- (void)keyUp:(NSEvent *)theEvent
{
    if([[theEvent characters] isEqual:@"w"])
        _inputHandler.up = NO;
	if([[theEvent characters] isEqual:@"s"])
        _inputHandler.down = NO;
	if([[theEvent characters] isEqual:@"a"])
        _inputHandler.left = NO;
	if([[theEvent characters] isEqual:@"d"])
        _inputHandler.right = NO;
}
#endif

-(void)update:(CFTimeInterval)currentTime {
	for(TankTank *tank in _game.currentLevel.tanks) {
		TankNode *tankNode = _tankSprites[tank.identifier];
		tankNode.position = tank.position.point;
		tankNode.zRotation = tank.rotation;
		tankNode.turret.zRotation = tank.turretRotation;
	}
	
	for(TankBullet *bullet in _game.currentLevel.bullets) {
		SKSpriteNode *sprite = _bulletSprites[bullet.identifier];
		sprite.position = bullet.position.point;
		sprite.zRotation = bullet.angle;
	}
}

@end

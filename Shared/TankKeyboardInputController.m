#import "TankKeyboardInputController.h"

#import "TankTankController.h"
#import "TankGame.h"
#import "TankTank.h"


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
//    tank.acceleration = [[Vector2 vectorWithX:0 y:movementSpeed * movementRate] vectorByRotatingByRadians:tank.rotation];
//    tank.angularAcceleration = M_PI * rotationSpeed * -turnRate;
    
    //    TankBullet *bullet = [TankBullet new];
    //    bullet.speed = 400;
    //    [[_game.currentLevel mutableArrayValueForKey:@"bullets"] addObject:bullet];
    //    bullet.position = _player.tank.position;
    //    bullet.angle = _player.tank.turretRotation + _player.tank.rotation;
    
    [super tickWithTank:tank delta:delta];
}

@end


@implementation PlayerInputState

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

#import <Foundation/Foundation.h>
#import "TankTankController.h"

@class TankTank;
@class TankGame;

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


/**
 Server component: Implementation of tick function
 **/
@interface TankControlsTank : KeyboardInputTankController
@property (nonatomic, strong) TankGame *game;
@end


/**
 Client: Holds the players current input state/intent.
 **/
@interface PlayerInputState : NSObject
@property (nonatomic, assign) BOOL up;
@property (nonatomic, assign) BOOL down;
@property (nonatomic, assign) BOOL left;
@property (nonatomic, assign) BOOL right;
@property (nonatomic, assign) BOOL fire;
@property (nonatomic, copy) Vector2 *targetPoint;
@end


/** 
 Server side of PlayerInputState: Modifies a tank controller
 **/
@interface TankPlayerInputHandler : PlayerInputState
@property (nonatomic, strong) KeyboardInputTankController *tankControls;
@end

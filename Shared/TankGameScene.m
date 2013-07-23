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

@implementation TankGameScene
{
	TankGame *_game;
	TankPlayer *_me;
	SKSpriteNode *_meSprite;
	SKSpriteNode *_turretSprite;
}

-(id)initWithSize:(CGSize)size game:(TankGame*)game
{
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
		_game = game;
		_me = [[TankPlayer alloc] init];
		_me.name = @"Hej";
		_me.identifier = @"Fusk";
		[[game mutableArrayValueForKey:@"players"] addObject:_me];
		
		_meSprite = [SKSpriteNode spriteNodeWithImageNamed:@"Tank"];
		_meSprite.size = CGSizeMake(_meSprite.size.width*0.3, _meSprite.size.height*0.3);
		_turretSprite = [SKSpriteNode spriteNodeWithImageNamed:@"Turret"];
		_turretSprite.size = CGSizeMake(_turretSprite.size.width*0.3, _turretSprite.size.height*0.3);
		_turretSprite.anchorPoint = CGPointMake(0.5, 0.42);
		[_meSprite addChild:_turretSprite];
        [self addChild:_meSprite];
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
}
- (void)mouseDown:(NSEvent *)theEvent
{
	SKSpriteNode *bullet = [SKSpriteNode spriteNodeWithImageNamed:@"bulleta"];
	bullet.zRotation = _me.tank.turretRotation + _me.tank.rotation;
	bullet.position = _me.tank.position.point;
	
	Vector2 *bulletDest = [[Vector2 vectorWithX:0 y:500] vectorByRotatingByRadians:bullet.zRotation];
	[bullet runAction:[SKAction moveByX:bulletDest.x y:bulletDest.y duration:1]];
	[self addChild:bullet];
}
- (void)keyDown:(NSEvent *)theEvent
{
	if([[theEvent characters] isEqual:@"w"])
		_me.tank.acceleration = [[Vector2 vectorWithX:0 y:5000] vectorByRotatingByRadians:_me.tank.rotation];
	if([[theEvent characters] isEqual:@"s"])
		_me.tank.acceleration = [[Vector2 vectorWithX:0 y:-5000] vectorByRotatingByRadians:_me.tank.rotation];
	if([[theEvent characters] isEqual:@"a"])
		_me.tank.angularAcceleration = M_PI*80;
	if([[theEvent characters] isEqual:@"d"])
		_me.tank.angularAcceleration = -M_PI*80;
}
- (void)keyUp:(NSEvent *)theEvent
{
	if(_me.tank.acceleration.length)
		_me.tank.acceleration = [Vector2 zero];
	else if(_me.tank.angularAcceleration)
		_me.tank.angularAcceleration = 0;
}
#endif

-(void)update:(CFTimeInterval)currentTime {
	_meSprite.position = _me.tank.position.point;
	_meSprite.zRotation = _me.tank.rotation;
	_turretSprite.zRotation = _me.tank.turretRotation;
}

@end

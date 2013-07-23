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
		
		_meSprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        [self addChild:_meSprite];
    }
    return self;
}

#if TARGET_OS_IPHONE
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}
#else
-(void)mouseDown:(NSEvent *)theEvent
{

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
}

@end

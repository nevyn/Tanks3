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
		self.anchorPoint = CGPointMake(0, 1);
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
-(void)mouseDown:(NSEvent *)theEvent {

}
- (void)keyDown:(NSEvent *)theEvent
{
	if([[theEvent characters] isEqual:@"w"])
		_me.tank.position = [_me.tank.position vectorByAddingVector:[Vector2 vectorWithX:0 y:-10]];
	if([[theEvent characters] isEqual:@"s"])
		_me.tank.position = [_me.tank.position vectorByAddingVector:[Vector2 vectorWithX:0 y:10]];
}
#endif

-(void)update:(CFTimeInterval)currentTime {
	_meSprite.position = _me.tank.position.point;
	_meSprite.zRotation = _me.tank.rotation;
}

@end

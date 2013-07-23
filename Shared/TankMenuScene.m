//
//  TankMenuScene.m
//  Tanks3
//
//  Created by Joachim Bengtsson on 2013-07-23.
//  Copyright (c) 2013 Mastervone. All rights reserved.
//

#import "TankMenuScene.h"
#import "TankGameScene.h"

@implementation TankMenuScene
{
	SKLabelNode *_createGameButton;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        _createGameButton = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        _createGameButton.text = @"Create game!";
        _createGameButton.fontSize = 30;
        _createGameButton.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
        
        [self addChild:_createGameButton];
    }
    return self;
}

- (void)touchAt:(CGPoint)location
{
	if([self nodeAtPoint:location] == _createGameButton) {
		[self.delegate tankMenu:self requestsCreatingServerWithGameCallback:^(TankGame *game) {
			TankGameScene *gameScene = [[TankGameScene alloc] initWithSize:self.size game:(id)game];
			[self.view presentScene:gameScene transition:[SKTransition doorsOpenHorizontalWithDuration:1.0]];
		}];
	}
}

#if TARGET_OS_IPHONE
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchAt:[[touches anyObject] locationInNode:self]];
}
#else
-(void)mouseDown:(NSEvent *)theEvent {
    
    CGPoint location = [theEvent locationInNode:self];
	[self touchAt:location];
}
#endif


@end

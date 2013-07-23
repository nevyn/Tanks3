//
//  TankMenuScene.m
//  Tanks3
//
//  Created by Joachim Bengtsson on 2013-07-23.
//  Copyright (c) 2013 Mastervone. All rights reserved.
//

#import "TankMenuScene.h"
#import "TankGameScene.h"
#import "TankServer.h"
#import <SPSuccinct/SPSuccinct.h>

@interface TankMenuScene () <NSNetServiceBrowserDelegate>
@property(nonatomic,readonly) NSMutableArray *serviceLabels;
@property(nonatomic,readonly) NSMutableArray *foundServices;
@end

@implementation TankMenuScene
{
	SKLabelNode *_createGameButton;
	NSNetServiceBrowser *_browser;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        _createGameButton = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        _createGameButton.text = @"Create game";
        _createGameButton.fontSize = 30;
        _createGameButton.position = CGPointMake(200, self.frame.size.height-250);
        [self addChild:_createGameButton];
		
        SKLabelNode *joinLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
		joinLabel.fontColor = [SKColor grayColor];
        joinLabel.text = @"Join game:";
        joinLabel.fontSize = 30;
        joinLabel.position = CGPointMake(190, self.frame.size.height-300);
        [self addChild:joinLabel];
		
		_foundServices = [NSMutableArray new];
		_browser = [NSNetServiceBrowser new];
		_browser.delegate = self;
		[_browser searchForServicesOfType:TankBonjourType inDomain:@""];
		
		__weak __typeof(self) weakSelf = self;
		[self sp_addDependency:@"labels" on:@[self, @"foundServices"] changed:^{
			for(id label in weakSelf.serviceLabels)
				[label removeFromParent];
			[weakSelf.serviceLabels removeAllObjects];
			CGPoint pen = CGPointMake(450, weakSelf.frame.size.height-300);
			for(NSNetService *service in weakSelf.foundServices) {
				SKLabelNode *serviceLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
				serviceLabel.fontColor = [SKColor whiteColor];
				serviceLabel.text = service.name;
				serviceLabel.fontSize = 30;
				serviceLabel.position = pen;
				pen.y -= 70;
				[weakSelf addChild:serviceLabel];
				[weakSelf.serviceLabels addObject:serviceLabel];
			}
		}];
		

    }
    return self;
}

- (void)touchAt:(CGPoint)location
{
	if([self nodeAtPoint:location] == _createGameButton) {
		[self.delegate tankMenu:self requestsCreatingServerWithGameCallback:^(TankGame *game) {
			TankGameScene *gameScene = [[TankGameScene alloc] initWithSize:self.size game:(id)game];
			[self.view presentScene:gameScene transition:[SKTransition doorsOpenHorizontalWithDuration:0.35]];
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

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing;
{
	[[self mutableArrayValueForKey:@"foundServices"] addObject:aNetService];
}
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing;
{
	[[self mutableArrayValueForKey:@"foundServices"] removeObject:aNetService];
}



@end

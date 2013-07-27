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
#import <WorldKit/Client/Client.h>

@interface TankMenuScene () <NSNetServiceBrowserDelegate, NSNetServiceDelegate>
@property(nonatomic,readonly) NSMutableArray *serviceLabels;
@property(nonatomic,readonly) NSMutableArray *onlineServiceLabels;
@property(nonatomic,readonly) NSMutableArray *foundServices;
@property(nonatomic,readonly) SKLabelNode *createOnlineGameButton;
@property(nonatomic,readonly) WorldMasterClient *onlineMaster;
@end

@implementation TankMenuScene
{
	SKLabelNode *_createLocalGameButton;
	NSNetServiceBrowser *_browser;
}

-(id)initWithSize:(CGSize)size onlineMaster:(WorldMasterClient*)onlineMaster
{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        _onlineMaster = onlineMaster;
        
        SKLabelNode *heading = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        heading.text = @"Local Wifi";
        heading.fontSize = 30;
        heading.position = CGPointMake(50, self.frame.size.height-260);
        heading.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        heading.fontColor = [SKColor grayColor];
        [self addChild:heading];
        
        _createLocalGameButton = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        _createLocalGameButton.text = @"Create game";
        _createLocalGameButton.fontSize = 30;
        _createLocalGameButton.position = CGPointMake(50, self.frame.size.height-300);
        _createLocalGameButton.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        [self addChild:_createLocalGameButton];
        
        heading = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        heading.text = @"Online";
        heading.fontSize = 30;
        heading.position = CGPointMake(400, self.frame.size.height-260);
        heading.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        heading.fontColor = [SKColor grayColor];
        [self addChild:heading];
        
        _createOnlineGameButton = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        _createOnlineGameButton.fontSize = 30;
        _createOnlineGameButton.position = CGPointMake(400, self.frame.size.height-300);
        _createOnlineGameButton.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        [self addChild:_createOnlineGameButton];
        
		__weak __typeof(self) weakSelf = self;
        [self sp_addDependency:@"online state" on:@[SPD_PAIR(_onlineMaster, connected)] changed:^{
            if(weakSelf.onlineMaster.connected) {
                weakSelf.createOnlineGameButton.text = @"Create game";
                weakSelf.createOnlineGameButton.fontColor = [SKColor whiteColor];
            } else {
                 weakSelf.createOnlineGameButton.text = @"Connecting…";
                 weakSelf.createOnlineGameButton.fontColor = [SKColor grayColor];
            }
        }];

		_foundServices = [NSMutableArray new];
		_browser = [NSNetServiceBrowser new];
		_browser.delegate = self;
		[_browser searchForServicesOfType:TankBonjourType inDomain:@""];
		
		_serviceLabels = [NSMutableArray new];
		[self sp_addDependency:@"labels" on:@[self, @"foundServices"] changed:^{
			for(id label in weakSelf.serviceLabels)
				[label removeFromParent];
			[weakSelf.serviceLabels removeAllObjects];
			CGPoint pen = CGPointMake(70, weakSelf.frame.size.height-300);
			for(NSNetService *service in weakSelf.foundServices) {
				SKLabelNode *serviceLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
				serviceLabel.fontColor = [SKColor whiteColor];
				serviceLabel.text = service.name;
				serviceLabel.fontSize = 30;
				serviceLabel.position = pen;
                serviceLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
				pen.y -= 70;
				[weakSelf addChild:serviceLabel];
				[weakSelf.serviceLabels addObject:serviceLabel];
			}
		}];
        
        _onlineServiceLabels = [NSMutableArray new];
        [self sp_addDependency:@"more labels" on:@[SPD_PAIR(_onlineMaster, publicGames)] changed:^{
			for(id label in weakSelf.onlineServiceLabels)
				[label removeFromParent];
			[weakSelf.onlineServiceLabels removeAllObjects];
			CGPoint pen = CGPointMake(420, weakSelf.frame.size.height-300);
			for(WorldListedGame *service in weakSelf.foundServices) {
				SKLabelNode *serviceLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
				serviceLabel.fontColor = [SKColor whiteColor];
				serviceLabel.text = service.name;
				serviceLabel.fontSize = 30;
				serviceLabel.position = pen;
                serviceLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
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
	SKNode *hit = [self nodeAtPoint:location];
	
	if(hit == _createLocalGameButton) {
		[self.delegate tankMenuRequestsCreatingServer:self];
		return;
	}
    
    if(hit == _createOnlineGameButton) {
        [_onlineMaster createGameNamed:_onlineMaster.authenticatedPlayer.alias];
    }
    
	NSInteger i = [_serviceLabels indexOfObject:hit];
    if(i != NSNotFound) {
        NSNetService *service = _foundServices[i];
        service.delegate = self;
        [service resolveWithTimeout:5.0];
        return;
	}
    
    i = [_onlineServiceLabels indexOfObject:hit];
    if( i != NSNotFound) {
        WorldListedGame *game = _onlineMaster.publicGames[i];
        [_onlineMaster joinGameWithIdentifier:game.identifier];
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

- (void)netServiceDidResolveAddress:(NSNetService *)service;
{
	[self.delegate tankMenu:self requestsConnectingToServerAtHost:service.hostName port:service.port];
}
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict;
{
#if TARGET_OS_IPHONE
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't resolve" message:@"Sorry, couldn't find the game you tapped." delegate:nil cancelButtonTitle:@"Bummer" otherButtonTitles:nil];
	[alert show];
#else
	NSRunAlertPanel(@"Couldn't resolve", @"Sorry, couldn't resolve the domain of the instance you clicked.", @"Bummer", nil, nil);
#endif
}



@end

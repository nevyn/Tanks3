//
//  MVAppDelegate.m
//  MacTanks3
//
//  Created by Joachim Bengtsson on 2013-07-21.
//  Copyright (c) 2013 Mastervone. All rights reserved.
//

#import "MVAppDelegate.h"
#import "TankMenuScene.h"
#import "TankGameScene.h"
#import "TankServer.h"
#import <objc/runtime.h>

@interface MVAppDelegate () <TankMenuSceneDelegate, WorldMasterClientDelegate>
{
	TankServer *_server;
	WorldMasterClient *_client;
	NSString *_destinationHost;
	NSInteger _destinationPort;
}

@end

@implementation MVAppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	object_setClass(self.skView, [TankSKView class]);
	[self.window setAcceptsMouseMovedEvents:YES];
	
    TankMenuScene *scene = [TankMenuScene sceneWithSize:CGSizeMake(1024, 768)];
    scene.delegate = self;
    scene.scaleMode = SKSceneScaleModeAspectFit;
    [self.skView presentScene:scene];

    self.skView.showsFPS = YES;
    self.skView.showsNodeCount = YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)tankMenuRequestsCreatingServer:(TankMenuScene*)scene;
{
	_server = [TankServer new];
	[self tankMenu:scene requestsConnectingToServerAtHost:@"localhost" port:_server.master.usedListeningPort];
}

- (void)tankMenu:(TankMenuScene*)scene requestsConnectingToServerAtHost:(NSString*)hostName port:(NSInteger)port
{
	_destinationHost = hostName;
	_destinationPort = port;
	_client = [[WorldMasterClient alloc] initWithDelegate:self];
}

- (NSString*)nextMasterHostForMasterClient:(WorldMasterClient*)mc port:(int*)port
{
	*port = (int)_destinationPort;
	return _destinationHost;
}

-(void)masterClient:(WorldMasterClient*)mc wasDisconnectedWithReason:(NSString*)reason redirect:(NSURL*)url {}

-(void)masterClient:(WorldMasterClient *)mc failedGameCreationWithReason:(NSString*)reason {}
-(void)masterClient:(WorldMasterClient *)mc failedGameJoinWithReason:(NSString*)reason {}

-(void)masterClient:(WorldMasterClient *)mc isNowInGame:(WorldGameClient*)gameClient
{
	TankGameScene *gameScene = [[TankGameScene alloc] initWithSize:self.skView.scene.size gameClient:(id)gameClient];
	[self.skView presentScene:gameScene transition:[SKTransition doorsOpenHorizontalWithDuration:0.35]];
}

-(void)masterClientLeftCurrentGame:(WorldMasterClient *)mc
{
    TankMenuScene *scene = [TankMenuScene sceneWithSize:CGSizeMake(1024, 768)];
    scene.delegate = self;
    scene.scaleMode = SKSceneScaleModeAspectFit;

    [self.skView presentScene:scene transition:[SKTransition doorsCloseHorizontalWithDuration:0.35]];
}

@end


@implementation TankSKView
- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}
@end
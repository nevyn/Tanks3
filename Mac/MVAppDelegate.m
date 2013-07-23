//
//  MVAppDelegate.m
//  MacTanks3
//
//  Created by Joachim Bengtsson on 2013-07-21.
//  Copyright (c) 2013 Mastervone. All rights reserved.
//

#import "MVAppDelegate.h"
#import "TankMenuScene.h"
#import "TankServer.h"

@interface MVAppDelegate () <TankMenuSceneDelegate>
{
	TankServer *_server;
}

@end

@implementation MVAppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    /* Pick a size for the scene */
    TankMenuScene *scene = [TankMenuScene sceneWithSize:CGSizeMake(1024, 768)];
    scene.delegate = self;

    /* Set the scale mode to scale to fit the window */
    scene.scaleMode = SKSceneScaleModeAspectFit;

    [self.skView presentScene:scene];

    self.skView.showsFPS = YES;
    self.skView.showsNodeCount = YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)tankMenu:(TankMenuScene *)scene requestsCreatingServerWithGameCallback:(void (^)(TankGame *))callback
{
	_server = [TankServer new];
	callback((id)_server.gameServer.game);
}
@end

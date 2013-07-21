//
//  MVAppDelegate.m
//  MacTanks3
//
//  Created by Joachim Bengtsson on 2013-07-21.
//  Copyright (c) 2013 Mastervone. All rights reserved.
//

#import "MVAppDelegate.h"
#import "MVMyScene.h"

@implementation MVAppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    /* Pick a size for the scene */
    SKScene *scene = [MVMyScene sceneWithSize:CGSizeMake(1024, 768)];

    /* Set the scale mode to scale to fit the window */
    scene.scaleMode = SKSceneScaleModeAspectFit;

    [self.skView presentScene:scene];

    self.skView.showsFPS = YES;
    self.skView.showsNodeCount = YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end

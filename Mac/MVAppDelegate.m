#import "MVAppDelegate.h"
#import "TankSceneManager.h"

@implementation MVAppDelegate
{
	TankSceneManager *_sceneManager;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[self.window setAcceptsMouseMovedEvents:YES];
    /* Pick a size for the scene */
    TankMenuScene *scene = [TankMenuScene sceneWithSize:CGSizeMake(800, 600)];
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
@end

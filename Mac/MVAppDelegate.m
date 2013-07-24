#import "MVAppDelegate.h"
#import "TankSceneManager.h"

@implementation MVAppDelegate
{
	TankSceneManager *_sceneManager;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[self.window setAcceptsMouseMovedEvents:YES];
	_sceneManager = [[TankSceneManager alloc] initWithSpriteView:self.skView];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}
@end

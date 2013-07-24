#import "MVViewController.h"
#import "TankSceneManager.h"

@implementation MVViewController
{
	TankSceneManager *_sceneManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
	_sceneManager = [[TankSceneManager alloc] initWithSpriteView:skView];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskLandscape;
}

@end

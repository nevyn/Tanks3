#import "TankSceneManager.h"
#import "TankMenuScene.h"
#import "TankGameScene.h"
#import "TankServer.h"

@interface TankSceneManager () <TankMenuSceneDelegate, WorldMasterClientDelegate>
{
	TankServer *_server;
	WorldMasterClient *_client;
	NSString *_destinationHost;
	NSInteger _destinationPort;
}

@end

@implementation TankSceneManager
- (id)initWithSpriteView:(SKView*)view;
{
	if(self = [super init]) {
		self.skView = view;
		
		TankMenuScene *scene = [TankMenuScene sceneWithSize:CGSizeMake(800, 600)];
		scene.delegate = self;
		scene.scaleMode = SKSceneScaleModeAspectFit;
		[self.skView presentScene:scene];

		self.skView.showsFPS = YES;
		self.skView.showsNodeCount = YES;

	}
	return self;
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
	[_client disconnect];
	_client = nil;
	
    TankMenuScene *scene = [TankMenuScene sceneWithSize:CGSizeMake(1024, 768)];
    scene.delegate = self;
    scene.scaleMode = SKSceneScaleModeAspectFit;

    [self.skView presentScene:scene transition:[SKTransition doorsCloseHorizontalWithDuration:0.35]];
}

@end

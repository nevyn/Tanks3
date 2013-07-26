#import "TankSceneManager.h"
#import <SPSuccinct/SPSuccinct.h>
#import "TankMenuScene.h"
#import "TankGameScene.h"
#import "TankServer.h"
#import "TankSplashScene.h"

static const CGSize kSceneSize = {800, 600};

static const float kTransitionDuration = 0.6;

@interface TankSceneManager () <TankMenuSceneDelegate, WorldMasterClientDelegate>
{
	TankServer *_server;
	WorldMasterClient *_master;
    WorldGameClient *_gameClient;
	NSString *_destinationHost;
	NSInteger _destinationPort;
}
@end

@implementation TankSceneManager
- (id)initWithSpriteView:(SKView*)view;
{
	if(self = [super init]) {
		self.skView = view;
		
		TankMenuScene *scene = [TankMenuScene sceneWithSize:kSceneSize];
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
	_master = [[WorldMasterClient alloc] initWithDelegate:self];
    [self.skView presentScene:[[TankTextScene alloc] initWithSize:kSceneSize text:@"Connecting..."] transition:[SKTransition crossFadeWithDuration:kTransitionDuration]];
}

- (NSString*)nextMasterHostForMasterClient:(WorldMasterClient*)mc port:(int*)port
{
	*port = (int)_destinationPort;
	return _destinationHost;
}

-(void)masterClient:(WorldMasterClient*)mc wasDisconnectedWithReason:(NSString*)reason redirect:(NSURL*)url
{
    [self returnToMenu];
}

-(void)masterClient:(WorldMasterClient *)mc failedGameCreationWithReason:(NSString*)reason
{
    [self returnToMenu];
}
-(void)masterClient:(WorldMasterClient *)mc failedGameJoinWithReason:(NSString*)reason
{
    [self returnToMenu];
}

-(void)masterClient:(WorldMasterClient *)mc isNowInGame:(WorldGameClient*)gameClient
{
    _gameClient = gameClient;
    [self sp_addDependency:@"state" on:@[_gameClient, @"game.state"] target:self action:@selector(stateChanged)];
}

-(void)masterClientLeftCurrentGame:(WorldMasterClient *)mc
{
    [self returnToMenu];
}

- (TankGame*)game
{
    return (id)_gameClient.game;
}

- (void)stateChanged
{
    // Wait for the game to arrive
    if(!self.game)
        return;
    
    // Switch to game scene if it's appropriate, and it's not already presented. Ditto for splash.
    SKScene *currentScene = self.skView.scene;
    if([self.game state] == TankGameStateInGame) {
        TankGameScene *gameScene = [currentScene isKindOfClass:[TankGameScene class]] ? (id)currentScene : nil;
        if(!gameScene || gameScene.level != self.game.currentLevel) {
            TankGameScene *gameScene = [[TankGameScene alloc] initWithSize:kSceneSize gameClient:_gameClient];
            [self.skView presentScene:gameScene transition:[SKTransition doorsOpenHorizontalWithDuration:kTransitionDuration]];
        }
    } else {
        if(![currentScene isKindOfClass:[TankSplashScene class]]) {
            TankSplashScene *splash = [[TankSplashScene alloc] initWithSize:kSceneSize gameClient:_gameClient];
            [self.skView presentScene:splash
             transition:[SKTransition moveInWithDirection:SKTransitionDirectionUp duration:kTransitionDuration]];
        }
    }
}

- (void)returnToMenu
{
	[_master disconnect];
	_master = nil;
    _gameClient = nil;
    
    [_server stop];
    _server = nil;
    
    if([self.skView.scene isKindOfClass:[TankMenuScene class]])
        return;
	
    TankMenuScene *scene = [TankMenuScene sceneWithSize:kSceneSize];
    scene.delegate = self;
    scene.scaleMode = SKSceneScaleModeAspectFit;
    
    SKTransition *transition = [self.skView.scene isKindOfClass:[TankTextScene class]] ?
        [SKTransition crossFadeWithDuration:kTransitionDuration] :
        [SKTransition doorsCloseHorizontalWithDuration:kTransitionDuration];
    [self.skView presentScene:scene transition:transition];
}

@end

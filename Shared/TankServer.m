#define WORLD_WRITABLE_MODEL 1
#import "TankServer.h"
#import <WorldKit/WorldKit.h>
#import "TankWorld/TankGame.h"
#import "TankWorld/TankPlayer.h"
#import <SPSuccinct/SPSuccinct.h>

@interface TankServer () <WorldMasterServerDelegate, NSNetServiceDelegate>
@end

@implementation TankServer {
    WorldMasterServer *_master;
	NSNetService *_publisher;
}

- (id)init
{
    if (!(self = [super init]))
        return nil;
    
    _master = [[WorldMasterServer alloc] initListeningOnBasePort:kTankServerPort];
    _master.delegate = self;
    NSError *err = nil;
	NSDictionary *params = @{WorldMasterServerParamGameName: @"Test game"};
    _gameServer = [_master createGameServerWithParameters:params error:&err];
    NSAssert(_gameServer != nil, @"Failed game creation: %@", err);
    [_master serveOnlyGame:_gameServer];
	
	[self publishAvoidingCollision:NO];
	
#if TARGET_OS_IPHONE
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unpublish) name:UIApplicationWillTerminateNotification object:nil];
#else
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unpublish) name:NSApplicationWillTerminateNotification object:nil];
#endif
    
    [NSTimer scheduledTimerWithTimeInterval:1/60. target:self selector:@selector(tick) userInfo:nil repeats:YES];
    
    return self;
}

- (WorldGameServer*)masterServer:(WorldMasterServer*)master createGameForRequest:(NSDictionary*)dict error:(NSError**)err;
{
    WorldGameServer *newGameServer = [[WorldGameServer alloc] initWithGameClass:[TankGame class] playerClass:[TankPlayer class] heartBeatRate:60.];
    
    return newGameServer;
}

- (void)tick
{
	[$cast(TankGame, _gameServer.game) tick:1/60.];
}

#pragma mark NSNetService

- (void)publishAvoidingCollision:(BOOL)avoidCollision
{
	NSString *collisionAvoidance = @"";
	if(avoidCollision) {
		NSArray *components = [_publisher.name componentsSeparatedByString:@" "];
		int v = [[components lastObject] intValue];
		collisionAvoidance = [NSString stringWithFormat:@" %d", v + 1];
	}
	NSString *pubName = [NSString stringWithFormat:@"%@%@", _gameServer.game.name, collisionAvoidance];
	
	[_publisher stop];
	
	_publisher = [[NSNetService alloc] initWithDomain:@"" type:TankBonjourType name:pubName port:_master.usedListeningPort];
	_publisher.delegate = self;

	[_publisher publish];
}

- (void)unpublish
{
	[_publisher stop];
}

/* Sent to the NSNetService instance's delegate when the publication of the instance is complete and successful.
*/
- (void)netServiceDidPublish:(NSNetService *)sender;
{
	NSLog(@"TankWorld successfully published");
}

/* Sent to the NSNetService instance's delegate when an error in publishing the instance occurs. The error dictionary will contain two key/value pairs representing the error domain and code (see the NSNetServicesError enumeration above for error code constants). It is possible for an error to occur after a successful publication.
*/
- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict;
{
	NSLog(@"TankWorld failed to publish: %@", errorDict);
	
	if([[errorDict valueForKey:NSNetServicesErrorCode] intValue] == NSNetServicesCollisionError)
		[self publishAvoidingCollision:YES];
}

/* Sent to the NSNetService instance's delegate when an error in resolving the instance occurs. The error dictionary will contain two key/value pairs representing the error domain and code (see the NSNetServicesError enumeration above for error code constants).
*/
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict;
{
	NSLog(@"TankWorld resolution failed: %@", errorDict);
}


@end

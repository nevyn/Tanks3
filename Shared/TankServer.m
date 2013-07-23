#define WORLD_WRITABLE_MODEL 1
#import "TankServer.h"
#import <WorldKit/WorldKit.h>
#import "TankWorld/TankGame.h"
#import "TankWorld/TankPlayer.h"
#import <SPSuccinct/SPSuccinct.h>

@interface TankServer () <WorldMasterServerDelegate>
@end

@implementation TankServer {
    WorldMasterServer *_master;
}

- (id)init
{
    if (!(self = [super init]))
        return nil;
    
    _master = [[WorldMasterServer alloc] initListeningOnPort:kTankServerPort];
    _master.delegate = self;
    NSError *err = nil;
    _gameServer = [_master createGameServerWithParameters:@{WorldMasterServerParamGameName: @"Test game"} error:&err];
    NSAssert(_gameServer != nil, @"Failed game creation: %@", err);
    [_master serveOnlyGame:_gameServer];
    
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

@end

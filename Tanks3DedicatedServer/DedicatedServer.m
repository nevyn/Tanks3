#import <Foundation/Foundation.h>
#import <WorldKit/Server/Server.h>
#import "Shared/TankWorld/TankTypes.h"
#import "Shared/TankWorld/TankGame.h"
#import "Shared/TankWorld/TankPlayer.h"

@interface TankDedicatedServer : NSObject <WorldMasterServerDelegate>
@property(nonatomic,readonly) WorldMasterServer *master;
@property(nonatomic,readonly) NSMutableArray *livingGames;
@end

@implementation TankDedicatedServer
{
    NSTimer *_tickTimer;
}
- (id)init
{
    if(self = [super init]) {
        _livingGames = [NSMutableArray new];
        _master = [[WorldMasterServer alloc] initListeningOnBasePort:kTankServerPort];
        _master.delegate = self;
        _tickTimer = [NSTimer scheduledTimerWithTimeInterval:1/60. target:self selector:@selector(tick) userInfo:nil repeats:YES];
    }
    return self;
}

- (WorldGameServer*)masterServer:(WorldMasterServer*)master createGameForRequest:(NSDictionary*)dict error:(NSError**)err;
{
    WorldGameServer *newGameServer = [[WorldGameServer alloc] initWithGameClass:[TankGame class] playerClass:[TankPlayer class] heartBeatRate:60.];
    [_livingGames addObject:newGameServer];
    
    return newGameServer;
}

- (void)tick
{
    for(WorldGameServer *server in _livingGames) {
        [(TankGame*)server.game tick:1/60.];
    }
}
@end


int main(int argc, const char * argv[])
{

    @autoreleasepool {
        TankDedicatedServer *server = [TankDedicatedServer new];
        [[NSRunLoop currentRunLoop] run];
        (void)server;
    }
    return 0;
}


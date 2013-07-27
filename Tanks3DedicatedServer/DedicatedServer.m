#import <Foundation/Foundation.h>
#import <WorldKit/Server/Server.h>
#import "Shared/TankWorld/TankTypes.h"
#import "Shared/TankWorld/TankGame.h"
#import "Shared/TankWorld/TankPlayer.h"

@interface TankDedicatedServer : NSObject <WorldMasterServerDelegate>
@property(nonatomic,readonly) WorldMasterServer *master;
@end

@implementation TankDedicatedServer
- (id)init
{
    if(self = [super init]) {
        _master = [[WorldMasterServer alloc] initListeningOnBasePort:kTankServerPort];
        _master.delegate = self;
    }
    return self;
}

- (WorldGameServer*)masterServer:(WorldMasterServer*)master createGameForRequest:(NSDictionary*)dict error:(NSError**)err;
{
    WorldGameServer *newGameServer = [[WorldGameServer alloc] initWithGameClass:[TankGame class] playerClass:[TankPlayer class] heartBeatRate:60.];
    
    return newGameServer;
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


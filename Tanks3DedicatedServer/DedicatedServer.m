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
        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(dumpStats) userInfo:nil repeats:YES];
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
    for(WorldGameServer *server in [_livingGames copy]) {
        if(server.game.players.count == 0) {
            [_master stopGame:server];
            [_livingGames removeObject:server];
        }
        
        [(TankGame*)server.game tick:1/60.];
    }
}

- (void)dumpStats
{
    printf("Stats:\n");
    printf("   %-1s %-24s %-5s %-5s %-16s\n", "#", "Name", "Lvl", "State", "Players");
    int i = 0;
    for(WorldGameServer *server in _livingGames) {
        TankGameState state = [(TankGame*)[server game] state];
        const char *map[] = {"Unk", "Splash", "Game", "Win", "Win!", "Dead", "Haxx"};
        const char *stateS = map[MIN(state, 6)];
        printf("  %02d %-24s %-5d %-5s %-16s\n",
            i,
            [[[server game] name] UTF8String],
            [(TankGame*)[server game] levelNumber],
            stateS,
            [[[[server game] valueForKeyPath:@"players.name"] componentsJoinedByString:@", "] UTF8String]
        );
        i++;
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


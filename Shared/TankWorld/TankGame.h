#import <WorldKit/Shared/Shared.h>
@class TankLevel;

@interface PlayerInputState : NSObject
@property (nonatomic, assign) BOOL up;
@property (nonatomic, assign) BOOL right;
@property (nonatomic, assign) BOOL down;
@property (nonatomic, assign) BOOL left;
- (NSDictionary*)rep;
- (id)initWithRep:(NSDictionary*)rep;
@end

typedef enum {
    TankGameStateLoading = 0,   // Loading the next level
    TankGameStateSplash,        // Next level is loaded, show quick info
    TankGameStateInGame,        // BATTLE!
    TankGameStateWin,           // Win, show results
    TankGameStateGameOver       // Game over
} TankGameState;

@class SKPhysicsWorld;

@interface TankGame : WorldGame
@property(nonatomic,WORLD_WRITABLE) TankGameState state;
@property(nonatomic,WORLD_WRITABLE) TankLevel *currentLevel;


// Move these to level?
// Or maybe move more stuff here from level?
@property(nonatomic,readonly) WORLD_ARRAY *enemyTanks;
@property(nonatomic,strong) SKPhysicsWorld *world;

- (void)tick:(float)delta;

-(void)explosionAt:(Vector2*)position;

/** When called client-side, updates the calling player's tank at the given
	world coordinate. */
- (void)cmd_aimTankAt:(Vector2*)aimAt;

/** When called client-side, fires the calling player's tank. */
- (void)cmd_fire;

/** When called client-side, changes the movement settings for the calling player's tank. */
- (void)cmd_moveTank:(PlayerInputState*)state;

/** When called client-side, lays a mine under the calling player's tank */
- (void)cmd_layMine;

@end

@interface TankGameServer : TankGame

- (void)startLevel:(int)levelNumber;

@end

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
    TankGameStateUnknown,
    TankGameStateSplash,        // Prepare for next level
    TankGameStateInGame,        // BATTLE!
    TankGameStateWin,           // Win, show results
    TankGameStateCompleteWin,   // Win, no more levels available
    TankGameStateGameOver       // Game over
} TankGameState;

@class SKPhysicsWorld;

@interface TankGame : WorldGame
@property(nonatomic,WORLD_WRITABLE) TankGameState state;
@property(nonatomic,WORLD_WRITABLE) TankLevel *currentLevel;
@property(nonatomic,WORLD_WRITABLE) int levelNumber;

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

/** When called client-side and game state is NOT InGame, make server load next level or otherwise progress game state. */
- (void)cmd_advanceGameState;

@end

@interface TankGameServer : TankGame

- (void)startLevel:(int)levelNumber;

@end

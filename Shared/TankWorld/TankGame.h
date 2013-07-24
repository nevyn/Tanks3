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

@class SKPhysicsWorld;

@interface TankGame : WorldGame
@property(nonatomic,WORLD_WRITABLE) TankLevel *currentLevel;
@property(nonatomic,readonly) WORLD_ARRAY *enemyTanks;
@property(nonatomic,strong) SKPhysicsWorld *world;

- (void)tick:(float)delta;

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
@end

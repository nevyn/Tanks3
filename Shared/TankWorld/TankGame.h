#import <WorldKit/Shared/Shared.h>
@class TankLevel;
static const int kTankServerPort = 29534;

@interface PlayerInputState : NSObject
@property (nonatomic, assign) BOOL forward;
@property (nonatomic, assign) BOOL reverse;
@property (nonatomic, assign) BOOL turnLeft;
@property (nonatomic, assign) BOOL turnRight;
- (NSDictionary*)rep;
- (id)initWithRep:(NSDictionary*)rep;
@end


@interface TankGame : WorldGame
@property(nonatomic,WORLD_WRITABLE) TankLevel *currentLevel;
@property(nonatomic,readonly) WORLD_ARRAY *enemyTanks;

- (void)tick:(float)delta;

/** When called client-side, updates the calling player's tank at the given
	world coordinate. */
- (void)cmd_aimTankAt:(Vector2*)aimAt;

/** When called client-side, fires the calling player's tank. */
- (void)cmd_fire;

/** When called client-side, changes the movement settings for the calling player's tank. */
- (void)cmd_moveTank:(PlayerInputState*)state;
@end

@interface TankGameServer : TankGame
@end

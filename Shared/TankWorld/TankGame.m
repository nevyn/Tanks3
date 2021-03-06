#define WORLD_WRITABLE_MODEL 1
#import <SPSuccinct/SPSuccinct.h>
#import <SpriteKit/SpriteKit.h>
#import "TankGame.h"
#import "TankPlayer.h"
#import "TankTank.h"
#import "TankEnemyTank.h"
#import "TankLevel.h"
#import "TankBullet.h"
#import "TankMine.h"
#import "BNZLine.h"
#import "SKPhysics+Private.h"

@interface TankGame () <SKPhysicsContactDelegate>

@end

@implementation TankGame

- (NSDictionary*)rep
{
    return WorldDictAppend([super rep], @{
        @"state": @(self.state),
        @"levelNumber": @(self.levelNumber),
		@"currentLevel": self.currentLevel.identifier ?: [NSNull null],
	});
}
- (void)updateFromRep:(NSDictionary*)rep fetcher:(WorldEntityFetcher)fetcher
{
    [super updateFromRep:rep fetcher:fetcher];
    WorldIf(rep, @"state", ^(id o) { self.state = [o intValue]; });
    WorldIf(rep, @"levelNumber", ^(id o) { self.levelNumber = [o intValue]; });
    WorldIf(rep, @"currentLevel", ^(id o) {
		self.currentLevel = [o isEqual:[NSNull null]] ? nil : fetcher(o, [TankLevel class], NO);
    });
}


- (void)tick:(float)delta
{
    [self.currentLevel tick:delta inGame:self];
    
    if(self.state == TankGameStateInGame) {
        if(self.currentLevel.enemyTanks.count == 0) {
            self.state = [TankLevel isLastLevel:self.currentLevel.levelNumber] ? TankGameStateCompleteWin : TankGameStateWin;
        } else if([[self.players valueForKeyPath:@"tank"] sp_all:^BOOL(id obj) { return [obj isEqual:[NSNull null]]; }]) {
            self.state = TankGameStateGameOver;
        }
    }
}

-(void)explosionAt:(Vector2*)position; {
}

- (void)cmd_aimTankAt:(Vector2*)aimAt;
{
	[self sendCommandToCounterpart:@"aimTankAt" arguments:@{
		@"aimAt": aimAt.rep,
	}];
}

- (void)cmd_fire
{
	[self sendCommandToCounterpart:@"fire" arguments:@{}];
}

- (void)cmd_moveTank:(PlayerInputState*)state
{
	[self sendCommandToCounterpart:@"moveTank" arguments:@{
		@"state": state.rep,
	}];
}

-(void)cmd_layMine
{
    [self sendCommandToCounterpart:@"layMine" arguments:@{}];
}

- (void)cmd_advanceGameState
{
    [self sendCommandToCounterpart:@"advanceGameState" arguments:@{}];
}
@end

@implementation TankGameServer
- (void)awakeFromPublish
{
    self.state = TankGameStateSplash;
	[super awakeFromPublish];
}


- (void)startLevel:(int)levelNumber
{
    self.currentLevel = [[TankLevel alloc] initWithLevel:levelNumber];
    self.levelNumber = self.currentLevel.levelNumber;
    [self.currentLevel startWithPlayers:self.players];
    self.state = TankGameStateInGame;
}


- (void)commandFromPlayer:(TankPlayer*)player aimTankAt:(NSDictionary*)args
{
	player.tank.aimingAt = [[Vector2 alloc] initWithRep:args[@"aimAt"]];
}

- (void)commandFromPlayer:(TankPlayer*)player fire:(NSDictionary*)args
{
    [player.tank fireBulletIntoLevel:self.currentLevel];
}

- (void)commandFromPlayer:(TankPlayer*)player moveTank:(NSDictionary*)args
{
	TankTank *playerTank = player.tank;
	
	PlayerInputState *state = [[PlayerInputState alloc] initWithRep:args[@"state"]];
    
    Vector2 *joystick = [Vector2 vectorWithPoint:state.joystick];

    if(joystick.length > 0) {
        playerTank.moveIntent = joystick;
    } else {
        MutableVector2 *moveIntent = [playerTank.moveIntent mutableCopy];
        moveIntent.x = state.right ? 1 : state.left ? -1 : 0;
        moveIntent.y = state.up ? 1 : state.down ? -1 : 0;
        playerTank.moveIntent = [moveIntent copy];
    }
    
    // Normalize so we don't go faster diagonally
    if([playerTank.moveIntent length] > 1.0)
        playerTank.moveIntent = [playerTank.moveIntent normalizedVector];
    
    // Something changed, so force recalc of canMove
    playerTank.canMove = NO;
}

-(void)commandFromPlayer:(TankPlayer*)player layMine:(NSDictionary*)args {
    [player.tank layMineIntoLevel:self.currentLevel];
}

- (void)commandFromPlayer:(TankPlayer*)player advanceGameState:(NSDictionary*)args
{
    if(self.state == TankGameStateInGame)
        return;
    int nextLevel = self.state == TankGameStateWin ? self.levelNumber + 1 : 0;
    [self startLevel:nextLevel];
}

@end

@implementation PlayerInputState
- (NSDictionary*)rep
{
	return @{
		@"up": @(_up),
		@"right": @(_right),
		@"down": @(_down),
		@"left": @(_left),
        @"joystick": NSStringFromCGPoint(_joystick),
	};
}
- (id)initWithRep:(NSDictionary*)rep
{
	if(self = [super init]) {
		self.up = [rep[@"up"] boolValue];
		self.right = [rep[@"right"] boolValue];
		self.down = [rep[@"down"] boolValue];
		self.left = [rep[@"left"] boolValue];
        self.joystick = CGPointFromString(rep[@"joystick"]);
	}
	return self;
}

@end
#define WORLD_WRITABLE_MODEL 1
#import <SPSuccinct/SPSuccinct.h>
#import "TankGame.h"
#import "TankPlayer.h"
#import "TankTank.h"
#import "TankLevel.h"
#import "TankBullet.h"

@implementation TankGame
- (void)tick:(float)delta
{
	for(TankTank *tank in [self.players valueForKeyPath:@"tank"]) {
		tank.velocity = [[tank.velocity vectorByAddingVector:[tank.acceleration vectorByMultiplyingWithScalar:delta]] vectorByMultiplyingWithScalar:0.9];
		tank.position = [tank.position vectorByAddingVector:[tank.velocity vectorByMultiplyingWithScalar:delta]];
		tank.angularVelocity = (tank.angularVelocity + tank.angularAcceleration*delta)*0.4;
		tank.rotation = tank.rotation + tank.angularVelocity*delta;
	}
	
	for(TankBullet *bullet in self.currentLevel.bullets) {
		bullet.position = [bullet.position vectorByAddingVector:[[Vector2 vectorWithX:0 y:delta*bullet.speed] vectorByRotatingByRadians:bullet.angle]];
	}
}
@end

@implementation TankGameServer
- (void)awakeFromPublish
{
	[super awakeFromPublish];
	
	self.currentLevel = [TankLevel new];
    
	[self sp_addObserver:self forKeyPath:@"players" options:NSKeyValueObservingOptionInitial callback:^(NSDictionary *change, id object, NSString *keyPath) {
		for(TankPlayer *player in [object players]) {
			if (!player.tank)
				player.tank = [TankTank new];
		}
	}];
}
@end

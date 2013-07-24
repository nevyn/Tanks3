//
//  TankEnemyTank.m
//  Tanks3
//
//  Created by Amanda Rösler on 2013-07-24.
//  Copyright (c) 2013 Mastervone. All rights reserved.
//
#define WORLD_WRITABLE_MODEL 1
#import "TankEnemyTank.h"
#import "TankGame.h"
#import "TankBullet.h"
#import "TankLevel.h"

@implementation TankEnemyTank

- (id)init
{
	if(self = [super init]) {
		_timeSinceFire = 0.0f;
	}
	return self;
}

- (void) update:(float)delta game:(TankGame*)game {
	
	TankTank *closestPlayer = [self closestPlayerToPosition:self.position players:[game.players valueForKeyPath:@"tank"]];
	if(!closestPlayer) return;
	
    self.aimingAt = closestPlayer.position;
    
    // Should fire?
    if (self.timeSinceFire > 3.f && [self.position distance:closestPlayer.position] < 250) {
		
		TankBullet *bullet = [TankBullet new];
		bullet.speed = TankBulletStandardSpeed;
		bullet.collisionTTL = 2;
		[[game.currentLevel mutableArrayValueForKey:@"bullets"] addObject:bullet];
		bullet.position = self.position;
		bullet.rotation = [self turretRotation] + self.rotation;
		[bullet updatePhysicsFromProperties];
		
		_timeSinceFire = 0.0f;
    }
    
    _timeSinceFire += delta;
	
	[self playersInSight:[game.players valueForKeyPath:@"tank"] game:game];
}

- (TankTank*) closestPlayerToPosition:(Vector2*)pos players:(NSArray*)allPlayers {
	
	TankTank *closestPlayer = NULL;
	float closestDistance = 0;
	for (TankTank *player in allPlayers) {
		float distance = [pos distance:player.position];
		if (!closestPlayer || distance < closestDistance) {
			closestPlayer = player;
			closestDistance = distance;
		}
	}
	
	return closestPlayer;
}

- (NSArray*) playersInSight:(NSArray*)allPlayers game:(TankGame*)game {
	
	NSMutableArray *inSight = [NSMutableArray array];
	
	for (TankTank *player in allPlayers) {
		
		[game.world enumerateBodiesAlongRayStart:self.position.point end:player.position.point usingBlock:^(SKPhysicsBody *body, CGPoint point, CGPoint normal, BOOL *stop) {
			
			// Do something here
		}];
	}
	
	return inSight;
}

@end

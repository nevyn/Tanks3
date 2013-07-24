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
#import "SKPhysics+Private.h"

@implementation TankEnemyTank

- (id)init
{
	if(self = [super init]) {
		_timeSinceFire = 0.0f;
		_timeSinceMovement = 0.0f;
	}
	return self;
}

- (void) update:(float)delta game:(TankGame*)game {
	
	TankTank *closestPlayer = [self closestPlayerToPosition:self.position players:[game.players valueForKeyPath:@"tank"]];
	
	TankTank *playerInSight = [self closestPlayerInSight:[game.players valueForKeyPath:@"tank"] game:game];
	
	[self updateMovement:delta game:game target:playerInSight];
	
	[self updateFiring:delta game:game playerInSight:playerInSight closestPlayer:closestPlayer];
}

- (void) updateFiring:(float)delta game:(TankGame*)game playerInSight:(TankTank*)playerInSight closestPlayer:(TankTank*)closestPlayer {
	
	if (!playerInSight) {
		if (closestPlayer) self.aimingAt = closestPlayer.position;
		return;
	}
	
    self.aimingAt = playerInSight.position;
	
	// Should fire?
    if (self.timeSinceFire > 2.f && [self.position distance:playerInSight.position] < 250) {
		
		[self fireBulletIntoLevel:game.currentLevel];		
		_timeSinceFire = 0.0f;
    }
    
    _timeSinceFire += delta;
}

- (void) updateMovement:(float)delta game:(TankGame*)game target:(TankTank*)target {
	
	_timeSinceMovement += delta;
	
	if (_timeSinceMovement < 2.0f) return;
	
	_timeSinceMovement = 0.0f;
	
	if (target) {
		Vector2 *direction = [[target.position vectorBySubtractingVector:self.position] normalizedVector];
		self.moveIntent = [direction vectorByMultiplyingWithScalar:0.2f];
		self.canMove = NO;
	}
	else {
		
		if (arc4random() % 100 > 75) {
			self.moveIntent = [Vector2 vectorWithX:0 y:0];
		}
		else {
			int x = (arc4random()%10)-5;
			int y = (arc4random()%10)-5;
			Vector2 *direction = [Vector2 vectorWithX:x y:y];
			
			if (x == 0 && y == 0) {
				self.moveIntent = direction;
			}
			else {
				self.moveIntent = [[direction normalizedVector] vectorByMultiplyingWithScalar:0.2f];
				self.canMove = NO;
			}
		}
	}
	
	
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

- (TankTank*) closestPlayerInSight:(NSArray*)allPlayers game:(TankGame*)game {
	
	NSMutableArray *inSight = [NSMutableArray array];
	
	for (TankTank *player in allPlayers) {
		
		__block id closestObstacle = NULL;
		__block float closestDistance = 0;
		
		[game.world enumerateBodiesAlongRayStart:self.position.point end:player.position.point usingBlock:^(SKPhysicsBody *body, CGPoint point, CGPoint normal, BOOL *stop) {
			
			id obstacle = SKPhysicsBodyGetUserData(body);
			if (body == self.physicsBody || [obstacle isKindOfClass:[TankBullet class]]) return;
			
			float distance = [self.position distance:[Vector2 vectorWithPoint:body.position]];
			
			if (!closestObstacle || distance < closestDistance) {
				closestObstacle = body;
				closestDistance = distance;
			}
		}];
		
		id closestObstacleUserData = SKPhysicsBodyGetUserData(closestObstacle);
		//NSLog(@"Closest obstacle: %@ (%@)", closestObstacleUserData, closestObstacle);
		
		if ([closestObstacleUserData isKindOfClass:[TankTank class]] && ![closestObstacleUserData isKindOfClass:[TankEnemyTank class]]) {
			//NSLog(@"Player is in sight!");
			[inSight addObject:closestObstacleUserData];
		}
	}
	
	return [self closestPlayerToPosition:self.position players:inSight];
}

@end

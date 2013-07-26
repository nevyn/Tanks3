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
		_timeSinceDirectionUpdate = 0.0f;
	}
	return self;
}

- (TankBullet*)fireBulletIntoLevel:(TankLevel*)level
{
    TankBullet *bullet = [super fireBulletIntoLevel:level];
    bullet.enemyBullet = YES;
    return bullet;
}

- (void) update:(float)delta game:(TankGame*)game {
	
	TankTank *closestPlayer = [self closestPlayerToPosition:self.position players:[game.players valueForKeyPath:@"tank"]];
	
	TankTank *playerInSight = [self closestPlayerInSight:[game.players valueForKeyPath:@"tank"] game:game];
	
	[self updateMovement:delta game:game playerInSight:playerInSight closestPlayer:closestPlayer];
	
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

- (void) updateMovement:(float)delta game:(TankGame*)game playerInSight:(TankTank*)playerInSight closestPlayer:(TankTank*)closestPlayer {
	
	_timeSinceMovement += delta;
	_timeSinceDirectionUpdate += delta;
	
	if (_timeSinceMovement < 0.5f) return;
	
	_timeSinceMovement = 0.0f;
	
	if (playerInSight) {
		
		if ([playerInSight.position distance:self.position] > 100.0f) {
			Vector2 *direction = [[playerInSight.position vectorBySubtractingVector:self.position] normalizedVector];
			self.moveIntent = [direction vectorByMultiplyingWithScalar:0.2f];
			self.canMove = NO;
		}
		else {
			self.moveIntent = [Vector2 vectorWithX:0 y:0];
		}
		
	}
	else if (closestPlayer) {
		
		Vector2 *currentMoveDirection = self.moveIntent;
		
		if (_timeSinceDirectionUpdate > 4.0f || (currentMoveDirection.x == 0 && currentMoveDirection.y == 0)) {
			currentMoveDirection = [[[closestPlayer.position vectorBySubtractingVector:self.position] normalizedVector] vectorByMultiplyingWithScalar:0.2f];
			_timeSinceDirectionUpdate = 0.0f;
		}
		
		CGPoint endPoint = [self.position vectorByAddingVector:[currentMoveDirection vectorByMultiplyingWithScalar:800]].point;
		
		CGPoint startPoint1 = [self.position vectorByAddingVector:[[[currentMoveDirection normalizedVector] vectorByRotatingByRadians:M_PI_2] vectorByMultiplyingWithScalar:20]].point;
		CGPoint startPoint2 = [self.position vectorByAddingVector:[[[currentMoveDirection normalizedVector] vectorByRotatingByRadians:-M_PI_2] vectorByMultiplyingWithScalar:20]].point;
		
		int i = 0;
		while ([game.currentLevel.world bodyAlongRayStart:startPoint1 end:endPoint] && [game.currentLevel.world bodyAlongRayStart:startPoint2 end:endPoint] && i < 100) {
			
			Vector2 *direction = [[closestPlayer.position vectorBySubtractingVector:self.position] normalizedVector];
			
			float x = direction.x + ((float)(arc4random()%24)-12)/10.0f;
			float y = direction.y + ((float)(arc4random()%24)-12)/10.0f;
			
			if (x == 0 && y == 0) {
				x = 1;
				y = 1;
			}
			
			Vector2 *randomDirection = [[Vector2 vectorWithX:x y:y] normalizedVector];
			currentMoveDirection = [randomDirection vectorByMultiplyingWithScalar:0.2f];
			endPoint = [self.position vectorByAddingVector:[currentMoveDirection vectorByMultiplyingWithScalar:800]].point;
			
			i++;
			if (i == 100) {
				currentMoveDirection = [currentMoveDirection vectorByMultiplyingWithScalar:-1.0f]; // failsafe
			}
		}
		
		self.moveIntent = currentMoveDirection;
		self.canMove = NO;
	}
	
	
}

- (TankTank*) closestPlayerToPosition:(Vector2*)pos players:(NSArray*)allPlayers {
	
	TankTank *closestPlayer = nil;
	float closestDistance = 0;
	for (TankTank *player in allPlayers) {
        if([player isEqual:[NSNull null]])
            continue;
        
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
        if([player isEqual:[NSNull null]])
            continue;
		
		__block id closestObstacle = NULL;
		__block float closestDistance = 0;
		
		[game.currentLevel.world enumerateBodiesAlongRayStart:self.position.point end:player.position.point usingBlock:^(SKPhysicsBody *body, CGPoint point, CGPoint normal, BOOL *stop) {
			
			id obstacle = SKPhysicsBodyGetUserData(body);
			if (body == self.physicsBody || [obstacle isKindOfClass:[TankBullet class]]) return;
						
			float distance = [self.position distance:[Vector2 vectorWithPoint:point]];
			
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

//
//  MVMyScene.m
//  Tanks3
//
//  Created by Joachim Bengtsson on 2013-07-21.
//  Copyright (c) 2013 Mastervone. All rights reserved.
//

#define WORLD_WRITABLE_MODEL 1
#import "TankGameScene.h"
#import "TankPlayer.h"
#import "TankTank.h"
#import "TankEnemyTank.h"
#import "TankLevel.h"
#import "TankBullet.h"
#import <SPSuccinct/SPSuccinct.h>

@interface TankGameScene ()
@property(nonatomic,readonly) NSMutableDictionary *bulletSprites;
@property(nonatomic,readonly) NSMutableDictionary *tankSprites;
@end

@interface TankNode : SKNode
@property(nonatomic) TankTank *tank;
@property(nonatomic) SKSpriteNode *body;
@property(nonatomic) SKSpriteNode *turret;
@end

@implementation TankNode

- (id)initWithTank:(TankTank*)tank
{
	if(self = [super init]) {
		self.tank = tank;
		
		_body = [SKSpriteNode spriteNodeWithImageNamed:@"Tank"];
		_body.size = CGSizeMake(_body.size.width*0.3, _body.size.height*0.3);
		_turret = [SKSpriteNode spriteNodeWithImageNamed:@"Turret"];
		_turret.size = CGSizeMake(_turret.size.width*0.3, _turret.size.height*0.3);
		_turret.anchorPoint = CGPointMake(0.5, 0.42);
		[_body addChild:_turret];
		[self addChild:_body];
	}
	return self;
}
@end

@implementation TankGameScene
{
	TankGame *_game;
	TankPlayer *_me;
}

-(id)initWithSize:(CGSize)size game:(TankGame*)clientGame hackyServerGame:(TankGame*)game;
{
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
		_game = game;
		_me = [[TankPlayer alloc] init];
		_me.name = @"Hej";
		_me.identifier = @"Fusk";
		[[game mutableArrayValueForKey:@"players"] addObject:_me];
		
		
		_bulletSprites = [NSMutableDictionary new];
		__weak __typeof(self) weakSelf = self;
		[_game.currentLevel sp_observe:@"bullets" removed:^(id bullet) {
			[weakSelf.bulletSprites[[bullet identifier]] removeFromParent];
			[weakSelf.bulletSprites removeObjectForKey:[bullet identifier]];
		} added:^(id bullet) {
			SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"bulleta"];
			sprite.size = CGSizeMake(sprite.size.width*0.3, sprite.size.height*0.3);
			[weakSelf addChild:sprite];
			weakSelf.bulletSprites[[bullet identifier]] = sprite;
		} initial:YES];
	  
		
		_tankSprites = [NSMutableDictionary new];
		[_game.currentLevel sp_observe:@"tanks" removed:^(id tank) {
			TankNode *node = [weakSelf tankSprites][[tank identifier]];
			[node removeFromParent];
			[weakSelf.tankSprites removeObjectForKey:[tank identifier]];
		} added:^(id tank) {
			TankNode *tankNode = [[TankNode alloc] initWithTank:tank];
			[weakSelf addChild:tankNode];
			[weakSelf tankSprites][[tank identifier]] = tankNode;
		} initial:YES];
	}
    return self;
}

- (void)didMoveToView:(SKView *)view
{
#if !TARGET_OS_IPHONE
	int opts = (NSTrackingActiveAlways | NSTrackingMouseMoved);
	NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:CGRectMake(0, 0, self.size.width, self.size.height)
                                                 options:opts
                                                   owner:self
                                                userInfo:nil];
	[self.view addTrackingArea:area];
#endif
}

#if TARGET_OS_IPHONE
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}
#else
- (void)mouseMoved:(NSEvent *)theEvent
{
	_me.tank.aimingAt = [Vector2 vectorWithPoint:[theEvent locationInNode:self]];
}
- (void)mouseDown:(NSEvent *)theEvent
{
	TankBullet *bullet = [TankBullet new];
	bullet.speed = 1000;
	bullet.collisionTTL = 2;
	[[_game.currentLevel mutableArrayValueForKey:@"bullets"] addObject:bullet];
	bullet.position = _me.tank.position;
	bullet.angle = _me.tank.turretRotation + _me.tank.rotation;
}
- (void)keyDown:(NSEvent *)theEvent
{
	if([[theEvent characters] isEqual:@"w"])
		_me.tank.acceleration = [[Vector2 vectorWithX:0 y:5000] vectorByRotatingByRadians:_me.tank.rotation];
	if([[theEvent characters] isEqual:@"s"])
		_me.tank.acceleration = [[Vector2 vectorWithX:0 y:-5000] vectorByRotatingByRadians:_me.tank.rotation];
	if([[theEvent characters] isEqual:@"a"])
		_me.tank.angularAcceleration = M_PI*80;
	if([[theEvent characters] isEqual:@"d"])
		_me.tank.angularAcceleration = -M_PI*80;
}
- (void)keyUp:(NSEvent *)theEvent
{
	if(_me.tank.acceleration.length)
		_me.tank.acceleration = [Vector2 zero];
	else if(_me.tank.angularAcceleration)
		_me.tank.angularAcceleration = 0;
}
#endif

-(void)update:(CFTimeInterval)currentTime {
	for(TankTank *tank in _game.currentLevel.tanks) {
		TankNode *tankNode = _tankSprites[tank.identifier];
		tankNode.position = tank.position.point;
		tankNode.zRotation = tank.rotation;
		tankNode.turret.zRotation = tank.turretRotation;
	}
	
	for(TankBullet *bullet in _game.currentLevel.bullets) {
		SKSpriteNode *sprite = _bulletSprites[bullet.identifier];
		sprite.position = bullet.position.point;
		sprite.zRotation = bullet.angle;
	}
}

@end

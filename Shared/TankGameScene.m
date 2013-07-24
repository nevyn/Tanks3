#import <WorldKit/Client/Client.h>
#import "TankGameScene.h"
#import "TankPlayer.h"
#import "TankTank.h"
#import "TankEnemyTank.h"
#import "TankLevel.h"
#import "TankBullet.h"
#import <SPSuccinct/SPSuccinct.h>

const static int tileSize = 30;

@interface TankGameScene ()
@property(nonatomic,readonly) SKSpriteNode *arena; // Main area, where the battle is!
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
		_body.size = CGSizeMake(30, 45);
        _body.anchorPoint = CGPointMake(0.5, 0.5);
		_turret = [SKSpriteNode spriteNodeWithImageNamed:@"Turret"];
		_turret.size = CGSizeMake(20, 35);
		_turret.position = CGPointMake(0, -7);
		_turret.anchorPoint = CGPointMake(0.5, 0.25);
		[_body addChild:_turret];
		[self addChild:_body];
	}
	return self;
}
@end

@implementation TankGameScene
{
    WorldGameClient *_client;
	TankGame *_hackyServerGame;
	PlayerInputState *_inputState;

    SKSpriteNode *_floor; // Background
    
    // ...stuff around arena...

    SKNode *_map;   // Container for tilemap
}

-(id)initWithSize:(CGSize)size gameClient:(WorldGameClient*)client
{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
		_client = client;
		_inputState = [PlayerInputState new];
        
        _arena = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:0.25 green:0.25 blue:0.5 alpha:1.0] size:CGSizeMake(660, 480)];
        _arena.anchorPoint = CGPointMake(0, 0);
        _arena.position = CGPointMake((800 - 660) / 2, (600-480)/2); // Move up-right a bit
        [self addChild:_arena];
        
        [self bindUIToDataModel];
	}
    return self;
}

- (void)bindUIToDataModel
{
    _bulletSprites = [NSMutableDictionary new];
    __weak __typeof(self) weakSelf = self;
    [_client sp_observe:@"game.currentLevel.bullets" removed:^(id bullet) {
        if(!bullet) return;
        [weakSelf.bulletSprites[[bullet identifier]] removeFromParent];
        [weakSelf.bulletSprites removeObjectForKey:[bullet identifier]];
    } added:^(id bullet) {
        if(!bullet) return;
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"bulleta"];
        sprite.size = CGSizeMake(25, 15);
        [weakSelf.arena addChild:sprite];
        weakSelf.bulletSprites[[bullet identifier]] = sprite;
    } initial:YES];
    
    //_floor = [SKSpriteNode spriteNodeWithImageNamed:@"floor"];
    //[self addChild:_floor];
    
    [self sp_addDependency:@"map" on:@[_client, @"game.currentLevel.map"] changed:^{
        __strong __typeof(self) strongSelf = weakSelf;
        [strongSelf->_map removeFromParent];
        
        strongSelf->_map = [SKNode node];
        strongSelf->_map.position = CGPointMake(0, 0);
        
        int x = -1;
        int y = 0;
        for(NSNumber *n in strongSelf.game.currentLevel.map) {
            x++;
            if(x == arenaWidth) {
                x = 0;
                y++;
            }

            NSInteger val = [n integerValue];
            if(val == 0) {
                continue;
            }
            NSString *tex = val == 1 ? @"wall" : @"breakable";
            
            SKSpriteNode *n = [SKSpriteNode spriteNodeWithImageNamed:tex];
            n.size = CGSizeMake(tileSize, tileSize);
            n.position = CGPointMake(x * tileSize, y * tileSize);
            n.anchorPoint = CGPointMake(0, 0);
            [strongSelf->_map addChild:n];
        }
    
        [strongSelf.arena addChild:strongSelf->_map];
    }];
    
    _tankSprites = [NSMutableDictionary new];
    [_client sp_observe:@"game.currentLevel.tanks" removed:^(id tank) {
        if(!tank) return;
        TankNode *node = [weakSelf tankSprites][[tank identifier]];
        [node removeFromParent];
        [weakSelf.tankSprites removeObjectForKey:[tank identifier]];
    } added:^(id tank) {
        if(!tank) return;
        TankNode *tankNode = [[TankNode alloc] initWithTank:tank];
        [weakSelf.arena addChild:tankNode];
        [weakSelf tankSprites][[tank identifier]] = tankNode;
    } initial:YES];
}

- (TankGame*)game
{
	return (id)_client.game;
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
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self.game cmd_aimTankAt:[Vector2 vectorWithPoint:[[touches anyObject] locationInNode:_arena]]];
	[self.game cmd_fire];

}

#else
- (void)mouseMoved:(NSEvent *)theEvent
{
	[self.game cmd_aimTankAt:[Vector2 vectorWithPoint:[theEvent locationInNode:_arena]]];
}
- (void)mouseDown:(NSEvent *)theEvent
{
	[self.game cmd_fire];
}
- (void)keyDown:(NSEvent *)theEvent
{
	if([[theEvent characters] isEqual:@"w"])
		_inputState.forward = YES;
	if([[theEvent characters] isEqual:@"s"])
		_inputState.reverse = YES;
	if([[theEvent characters] isEqual:@"a"])
		_inputState.turnLeft = YES;
	if([[theEvent characters] isEqual:@"d"])
		_inputState.turnRight = YES;
	[self.game cmd_moveTank:_inputState];
}
- (void)keyUp:(NSEvent *)theEvent
{
	if([[theEvent characters] isEqual:@"w"])
		_inputState.forward = NO;
	if([[theEvent characters] isEqual:@"s"])
		_inputState.reverse = NO;
	if([[theEvent characters] isEqual:@"a"])
		_inputState.turnLeft = NO;
	if([[theEvent characters] isEqual:@"d"])
		_inputState.turnRight = NO;
	[self.game cmd_moveTank:_inputState];
}
#endif

-(void)update:(CFTimeInterval)currentTime {
	for(TankTank *tank in self.game.currentLevel.tanks) {
		TankNode *tankNode = _tankSprites[tank.identifier];
		tankNode.position = tank.position.point;
		tankNode.zRotation = tank.rotation;
		tankNode.turret.zRotation = tank.turretRotation;
	}
	
	for(TankBullet *bullet in self.game.currentLevel.bullets) {
		SKSpriteNode *sprite = _bulletSprites[bullet.identifier];
		sprite.position = bullet.position.point;
		sprite.zRotation = bullet.angle;
	}
}

@end

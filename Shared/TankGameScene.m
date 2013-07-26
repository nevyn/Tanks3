#import <WorldKit/Client/Client.h>
#import "TankGameScene.h"
#import "TankPlayer.h"
#import "TankTank.h"
#import "TankEnemyTank.h"
#import "TankLevel.h"
#import "TankBullet.h"
#import "TankMine.h"
#import <SPSuccinct/SPSuccinct.h>

const static int tileSize = 30;

@interface TankGameScene ()
@property(nonatomic,readonly) SKSpriteNode *arena; // Main area, where the battle is!
@property(nonatomic,readonly) NSMutableDictionary *bulletSprites;
@property(nonatomic,readonly) NSMutableDictionary *tankSprites;
@property(nonatomic,readonly) NSMutableDictionary *mineSprites;
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
		_body.size = CGSizeMake(32, 39);
        _body.anchorPoint = CGPointMake(0.5, 0.5);
		_turret = [SKSpriteNode spriteNodeWithImageNamed:@"Turret"];
		_turret.size = CGSizeMake(24.2f, 48.8f);
		_turret.position = CGPointMake(0, 0);
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
    TankLevel *_currentLevel;
    
	PlayerInputState *_inputState;
    NSTimeInterval _tankTickSoundDuration[64];
    NSTimeInterval _lastFrame;

    SKSpriteNode *_floor; // Background
    
    // ...stuff around arena...

    SKNode *_map;   // Container for tilemap

#if !TARGET_OS_IPHONE
    NSTrackingArea *_trackingArea;
#endif
}

-(id)initWithSize:(CGSize)size gameClient:(WorldGameClient*)client
{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
		_client = client;
		_inputState = [PlayerInputState new];
        _currentLevel = [self game].currentLevel;
        
        _arena = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:0.25 green:0.25 blue:0.5 alpha:1.0] size:CGSizeMake(660, 480)];
        _arena.anchorPoint = CGPointMake(0, 0);
        _arena.position = CGPointMake((800 - 660) / 2, (600-480)/2); // Move up-right a bit
        [self addChild:_arena];
        
        [self bindUIToDataModel];
	}
    return self;
}

- (TankLevel*)level;
{
    return _currentLevel;
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
    
    _mineSprites = [NSMutableDictionary new];
    [_client sp_observe:@"game.currentLevel.mines" removed:^(id mine) {
        if(!mine) return;
        [weakSelf.mineSprites[[mine identifier]] removeFromParent];
        [weakSelf.mineSprites removeObjectForKey:[mine identifier]];
    } added:^(TankMine* mine) {
        if(!mine) return;
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"mine"];
        
        //NSLog(@"Släpp en mina...");
        //NSLog(@"Pos: %@ %f %f", [mine identifier], mine.position.x, mine.position.y);
        
        sprite.size = CGSizeMake(30,30);
        sprite.position = [mine.position point];
        [weakSelf.arena addChild:sprite];
        weakSelf.mineSprites[[mine identifier]] = sprite;
    }];
    
    //_floor = [SKSpriteNode spriteNodeWithImageNamed:@"floor"];
    //[self addChild:_floor];
    
    [self sp_addDependency:@"map" on:@[_client, @"game.currentLevel.map.map"] changed:^{
        __strong __typeof(self) strongSelf = weakSelf;
        [strongSelf->_map removeFromParent];
        
        strongSelf->_map = [SKNode node];
        strongSelf->_map.zPosition = 1;
        strongSelf->_map.position = CGPointMake(0, 0);
        
        int x = -1;
        int y = 0;
        for(NSNumber *n in strongSelf.game.currentLevel.map.map) {
            x++;
            if(x == arenaWidth) {
                x = 0;
                y++;
            }

            NSInteger val = [n integerValue];
            if(val == 0) {
                continue;
            }
            NSString *tex = @[@"floor", @"wall", @"breakable", @"hole"][val-1];
            
            SKSpriteNode *n = [SKSpriteNode spriteNodeWithImageNamed:tex];
            n.size = CGSizeMake(tileSize, tileSize);
            n.position = CGPointMake(x * tileSize, y * tileSize);
            n.anchorPoint = CGPointMake(0, 0);
            [strongSelf->_map addChild:n];
        }
    
        [strongSelf.arena insertChild:strongSelf->_map atIndex:0];
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

- (void)willMoveFromView:(SKView *)view
{
#if !TARGET_OS_IPHONE
    if(_trackingArea) {
        [view removeTrackingArea:_trackingArea];
        _trackingArea = nil;
    }
#endif
}

- (void)didMoveToView:(SKView *)view
{
#if !TARGET_OS_IPHONE
    if(view) {
        int opts = (NSTrackingActiveAlways | NSTrackingMouseMoved);
        _trackingArea = [[NSTrackingArea alloc] initWithRect:CGRectMake(0, 0, self.size.width, self.size.height) options:opts owner:self userInfo:nil];
        [self.view addTrackingArea:_trackingArea];
    }
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
    if([theEvent isARepeat]) return;
    
    if([[theEvent characters] isEqual:@" "]) {
        [self.game cmd_layMine];
        return;
    }
    
	if([[theEvent characters] isEqual:@"w"])
		_inputState.up = YES;
	if([[theEvent characters] isEqual:@"s"])
		_inputState.down = YES;
	if([[theEvent characters] isEqual:@"a"])
		_inputState.left = YES;
	if([[theEvent characters] isEqual:@"d"])
		_inputState.right = YES;
	[self.game cmd_moveTank:_inputState];
}
- (void)keyUp:(NSEvent *)theEvent
{    
	if([[theEvent characters] isEqual:@"w"])
		_inputState.up = NO;
	if([[theEvent characters] isEqual:@"s"])
		_inputState.down = NO;
	if([[theEvent characters] isEqual:@"a"])
		_inputState.left = NO;
	if([[theEvent characters] isEqual:@"d"])
		_inputState.right = NO;
	[self.game cmd_moveTank:_inputState];
}
#endif

-(void)update:(CFTimeInterval)currentTime {
    NSTimeInterval delta = currentTime - _lastFrame;
    
    int i = 0;
	for(TankTank *tank in self.game.currentLevel.tanks) {
		TankNode *tankNode = _tankSprites[tank.identifier];
		tankNode.position = tank.position.point;
		tankNode.zRotation = tank.rotation;
		tankNode.turret.zRotation = tank.turretRotation;
        
        _tankTickSoundDuration[i] += delta;
        if(_tankTickSoundDuration[i] > 0.075 && tank.velocity.length > 0) {
            [tankNode runAction:[SKAction playSoundFileNamed:[NSString stringWithFormat:@"step%d.wav", arc4random_uniform(4)] waitForCompletion:NO]];
            _tankTickSoundDuration[i] = 0;
        }
        i++;
	}
	
	for(TankBullet *bullet in self.game.currentLevel.bullets) {
		SKSpriteNode *sprite = _bulletSprites[bullet.identifier];
		sprite.position = bullet.position.point;
		sprite.zRotation = bullet.rotation;
	}
    
    for(TankMine *mine in self.game.currentLevel.mines) {
        SKSpriteNode *sprite = _mineSprites[mine.identifier];
        sprite.position = mine.position.point;
    }
    
    _lastFrame = currentTime;
}

@end

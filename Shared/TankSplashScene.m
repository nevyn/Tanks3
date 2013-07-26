#import "TankSplashScene.h"
#import <WorldKit/Client/Client.h>
#import <SPSuccinct/SPSuccinct.h>

@implementation TankSplashScene
{
    SKLabelNode *_stateLabel;
    SKLabelNode *_playersLabel;
    WorldGameClient *_client;
}
-(id)initWithSize:(CGSize)size gameClient:(WorldGameClient*)client
{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        _client = client;
        
        _stateLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        _stateLabel.text = @"";
        _stateLabel.fontSize = 30;
        _stateLabel.position = CGPointMake(size.width/2., size.height/2.);
        [self addChild:_stateLabel];
        
        _playersLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        _playersLabel.fontSize = 20;
        _playersLabel.fontColor = [SKColor grayColor];
        _playersLabel.position = CGPointMake(20, 20);
        _playersLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        [self addChild:_playersLabel];

        [self sp_addDependency:@"state" on:@[SPD_PAIR(self.game, state)] target:self action:@selector(stateChanged)];
        [self sp_addDependency:@"players" on:@[SPD_PAIR(self.game, players)] target:self action:@selector(playersChanged)];
    }
    return self;
}

- (TankGame*)game
{
    return (id)_client.game;
}

- (void)stateChanged
{
    if(self.game.state == TankGameStateUnknown) {
        _stateLabel.text = @"...";
    } else if(self.game.state == TankGameStateSplash) {
        _stateLabel.text = [NSString stringWithFormat:@"Prepare for level %d!", self.game.levelNumber+1];
        [self runAction:[SKAction playSoundFileNamed:@"splash.m4a" waitForCompletion:NO]];
    } else if(self.game.state == TankGameStateInGame) {
        _stateLabel.text = @"FIGHT!";
    } else if(self.game.state == TankGameStateWin) {
        _stateLabel.text = [NSString stringWithFormat:@"Victory!\nPrepare for level %d!", self.game.levelNumber + 2];
    } else if(self.game.state == TankGameStateCompleteWin) {
        _stateLabel.text = [NSString stringWithFormat:@"You win!!!"];
    } else if(self.game.state == TankGameStateGameOver) {
        _stateLabel.text = @"Game Over!\nTry again?";
    } else {
        _stateLabel.text = @"???";
    }
}

- (void)playersChanged
{
    _playersLabel.text = [NSString stringWithFormat:@"Players in game: %@", [[self.game.players valueForKeyPath:@"name"] componentsJoinedByString:@", "]];
}

- (void)advanceGameState
{
    if(self.game.state == TankGameStateCompleteWin) {
        [_client leave];
    }
    [(id)_client.game cmd_advanceGameState];
}

#if TARGET_OS_IPHONE
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self advanceGameState];
}
#else
- (void)mouseDown:(NSEvent *)theEvent
{
	[self advanceGameState];
}
#endif

@end

@implementation TankTextScene
- (id)initWithSize:(CGSize)size text:(NSString*)text
{
    if(self = [super initWithSize:size]) {
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        label.text = text;
        label.fontSize = 30;
        label.position = CGPointMake(size.width/2., size.height/2.);
        [self addChild:label];
    }
    return self;
}
@end

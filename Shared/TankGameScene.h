//
//  MVMyScene.h
//  Tanks3
//

//  Copyright (c) 2013 Mastervone. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "TankWorld/TankGame.h"
@class WorldGameClient;

@interface TankGameScene : SKScene
-(id)initWithSize:(CGSize)size gameClient:(WorldGameClient*)game;
@end

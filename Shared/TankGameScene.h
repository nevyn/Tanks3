//
//  MVMyScene.h
//  Tanks3
//

//  Copyright (c) 2013 Mastervone. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "TankWorld/TankGame.h"

@interface TankGameScene : SKScene
-(id)initWithSize:(CGSize)size game:(TankGame*)game;
@end

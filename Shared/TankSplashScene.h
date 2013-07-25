//
//  TankSplashScene.h
//  Tanks3
//
//  Created by Joachim Bengtsson on 2013-07-25.
//  Copyright (c) 2013 Mastervone. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "TankWorld/TankGame.h"
@class WorldGameClient;

@interface TankSplashScene : SKScene
-(id)initWithSize:(CGSize)size gameClient:(WorldGameClient*)client;
@end

// Dummy scene for when connecting, etc
@interface TankTextScene : SKScene
- (id)initWithSize:(CGSize)size text:(NSString*)text;
@end
//
//  TankMenuScene.h
//  Tanks3
//
//  Created by Joachim Bengtsson on 2013-07-23.
//  Copyright (c) 2013 Mastervone. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@class TankGame;
@protocol TankMenuSceneDelegate;

@interface TankMenuScene : SKScene
@property(weak) id<TankMenuSceneDelegate> delegate;
@end

@protocol TankMenuSceneDelegate <NSObject>
- (void)tankMenuRequestsCreatingServer:(TankMenuScene*)scene;
- (void)tankMenu:(TankMenuScene*)scene requestsConnectingToServerAtHost:(NSString*)hostName port:(NSInteger)port;
@end

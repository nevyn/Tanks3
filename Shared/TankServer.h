//
//  TankServer.h
//  Tanks3
//
//  Created by Joachim Bengtsson on 2013-07-23.
//  Copyright (c) 2013 Mastervone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WorldKit/WorldKit.h>

@interface TankServer : NSObject
@property(readonly) WorldGameServer *gameServer;
@end

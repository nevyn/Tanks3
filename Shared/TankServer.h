//
//  TankServer.h
//  Tanks3
//
//  Created by Joachim Bengtsson on 2013-07-23.
//  Copyright (c) 2013 Mastervone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WorldKit/WorldKit.h>

static NSString *const TankBonjourType = @"_mastervone_tanks._tcp";

@interface TankServer : NSObject
@property(readonly) WorldGameServer *gameServer;
@property(readonly) WorldMasterServer *master;

- (void)stop;
@end

//
//  TankEnemyTank.h
//  Tanks3
//
//  Created by Amanda Rösler on 2013-07-24.
//  Copyright (c) 2013 Mastervone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TankTank.h"

@class TankGame;

@interface TankEnemyTank : TankTank

@property (nonatomic, assign) float timeSinceFire;
@property (nonatomic, assign) float timeSinceMovement;

- (void) update:(float)delta game:(TankGame*)game;

@end

//
//  TankEnemyTank.m
//  Tanks3
//
//  Created by Amanda Rösler on 2013-07-24.
//  Copyright (c) 2013 Mastervone. All rights reserved.
//

#import "TankEnemyTank.h"

@implementation TankEnemyTank

- (id)init
{
	if(self = [super init]) {
    _timeSinceFire = 0.0f;
	}
	return self;
}

@end

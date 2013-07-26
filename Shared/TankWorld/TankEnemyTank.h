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

// http://strategywiki.org/wiki/Wii_Play/Tanks!
typedef enum {
    TankEnemyTypeBrown = 1, // immobile, 1 bullet, 1 ricochet, 0 mines, stupid
    TankEnemyTypeGrey = 2, // slow, 1 bullet, 1 ricochet, 0 mines, stupid
    TankEnemyTypeTeal = 3, // slow, 1 bullet, 0 ricochets, 0 mines, normal, ROCKET!
    TankEnemyTypeYellow = 4, // fast, 1 bullet, 1 ricochet, 4 mines, stupid
    TankEnemyTypeRed = 5, // normal, 3 bullets, 1 ricochet, 0 mines, normal
    TankEnemyTypeGreen = 6, // immobile, 2 bullets, 2 ricochets, 0 mines, clever, ROCKET!
    TankEnemyTypePurple = 7, // fast, 5 bullets, 1 ricochet, 2 mines, clever
    TankEnemyTypeWhite = 8, // normal, 5 bullets, 1 ricochet, 2 mines, normal, INVISIBLE!
    TankEnemyTypeBlack = 9, // fast, 2 bullets, 0 ricochet, 2 mines, genius, ROCKET
    
} TankEnemyType;

@interface TankEnemyTank : TankTank
@property (nonatomic, WORLD_WRITABLE) TankEnemyType enemyType;
@property (nonatomic, WORLD_WRITABLE) float timeSinceFire;
@property (nonatomic, WORLD_WRITABLE) float timeSinceMovement;
@property (nonatomic, WORLD_WRITABLE) float timeSinceDirectionUpdate;
- (void) update:(float)delta game:(TankGame*)game;
@end

#import <WorldKit/Shared/Shared.h>
#import "TankPhysicalEntity.h"

@class TankGame;

@interface TankMine : TankPhysicalEntity
@property(nonatomic,WORLD_WRITABLE) float timer;

- (void) update:(float)delta game:(TankGame*)game;

@end

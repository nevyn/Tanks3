#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface TankSceneManager : NSObject
@property (strong) SKView *skView;
- (id)initWithSpriteView:(SKView*)view;
@end

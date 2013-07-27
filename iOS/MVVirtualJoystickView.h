#import <UIKit/UIKit.h>
@protocol MVVirtualJoystickViewDelegate;

@interface MVVirtualJoystickView : UIView
@property(nonatomic,weak) id delegate;
@end


@protocol MVVirtualJoystickViewDelegate <NSObject>
- (void)virtualJoystick:(id)joystick changedDirectionTo:(CGPoint)direction;
@end
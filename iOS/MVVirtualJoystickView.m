#import "MVVirtualJoystickView.h"
#import "Vector2.h"

#define STICK_CENTER_TARGET_POS_LEN 20.0f

@implementation MVVirtualJoystickView 
{
    UIImageView *_base;
    UIImageView *_thumb;
}

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        _base = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stick_base.png"]];
        _thumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stick_normal.png"]];
        [self addSubview:_base];
        [self addSubview:_thumb];
        [self touchesCancelled:nil withEvent:nil];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _thumb.image = [UIImage imageNamed:@"stick_hold.png"];
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    float r = _base.frame.size.width/2;
    CGPoint p = [[touches anyObject] locationInView:_base];
    CGPoint center = _base.center;
    MutableVector2 *vec = [[MutableVector2 vectorWithPoint:p] subtractVector:[Vector2 vectorWithPoint:center]];
    
    if(vec.length > r)
        [[vec normalize] multiplyWithScalar:r];
    
    _thumb.center = [[Vector2 vectorWithPoint:center] vectorByAddingVector:vec].point;
    
    Vector2 *unitVec = [vec vectorByDividingWithScalar:r];
    
    [self.delegate virtualJoystick:self changedDirectionTo:unitVec.point];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesCancelled:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _thumb.image = [UIImage imageNamed:@"stick_normal.png"];
    _thumb.center = CGPointMake(CGRectGetMidX(_base.bounds), CGRectGetMidY(_base.bounds));
    [self.delegate virtualJoystick:self changedDirectionTo:CGPointZero];
}

@end

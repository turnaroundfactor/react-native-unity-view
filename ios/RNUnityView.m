#import "RNUnityView.h"

@implementation RNUnityView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    return self;
}

- (void)dealloc
{
}

- (void)setUnityView:(UIView *)view
{
    self.uView = view;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //[(UIView *)self.uView removeFromSuperview];
    //[self insertSubview:(UIView *)self.uView atIndex:0];
    NSLog(@"self.bounds: %i", self.bounds);
    ((UIView *)self.uView).frame = self.bounds;
    [(UIView *)self.uView setNeedsLayout];
}

@end

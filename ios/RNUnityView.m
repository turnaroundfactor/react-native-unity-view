#import "RNUnityView.h"

@implementation RNUnityView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame]; //https://developer.apple.com/documentation/uikit/uiview/1622488-initwithframe
    return self;
}

- (void)dealloc
{
}

- (void)setUnityView:(UIView *)view //this is not being called, i think this might be wear the issue is?
{
    NSLog(@"setUnityView inside function");
    self.uView = (RNUnityView *)view;
    [self setNeedsLayout]; //https://developer.apple.com/documentation/uikit/uiview/1622601-setneedslayout?language=objc
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [(UIView *)self.uView removeFromSuperview];
    [self insertSubview:(UIView *)self.uView atIndex:0];
    NSLog(@"self.bounds:%@", NSStringFromCGRect(self.frame));
    (self.uView).frame = self.bounds;
    [self.uView setNeedsLayout]; //https://developer.apple.com/documentation/uikit/uiview/1622601-setneedslayout?language=objc
}

@end

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

- (bool)unityIsInitialized {
    return [self ufw] && [[self ufw] appController];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //[(UIView *)self.uView removeFromSuperview];
    //[self insertSubview:(UIView *)self.uView atIndex:0];
    NSLog(@"self.bounds: %i", self.bounds);
    NSLog(@"self.bounds: %@", self.bounds);
    NSLog(@"%@", NSStringFromCGRect(self.frame));
    //((UIView *)self.uView).frame = self.bounds;
    //[(UIView *)self.uView setNeedsLayout];
    if([self unityIsInitialized]) {
      self.ufw.appController.rootView.frame = self.bounds;
      [self addSubview:self.ufw.appController.rootView];
   }
}

@end

#import "RNUnityViewManager.h"
#import "RNUnityView.h"

@implementation RNUnityViewManager

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE(RNUnityView)

- (UIView *)view
{
    self.currentView = [[RNUnityView alloc] init];
    if ([UnityUtils isUnityReady]) {
        NSLog(@"isUnityReady yes");
        [self.currentView setUnityView: (RNUnityView *)[GetAppController() unityView]];
    } else {
        NSLog(@"isUnityReady no"); // this is getting called
        [UnityUtils createPlayer:^{
           NSLog(@"createPlayer building view"); // this is not getting called
            [self.currentView setUnityView: (RNUnityView *)[GetAppController() unityView]]; //we are not getting the calls in here to happen
        }];
        [GetAppController() setUnityMessageHandler: ^(const char* message) {
            [_bridge.eventDispatcher sendDeviceEventWithName:@"onUnityMessage"
                                                            body:[NSString stringWithUTF8String:message]];
        }];
    }
    return self.currentView;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

- (void)setBridge:(RCTBridge *)bridge {
    _bridge = bridge;
}

RCT_EXPORT_METHOD(postMessage:(nonnull NSNumber *)reactTag gameObject:(NSString *)gameObject methodName:(NSString *)methodName message:(NSString *)message)
{
    UnityPostMessage(gameObject, methodName, message);
}

RCT_EXPORT_METHOD(pause:(nonnull NSNumber *)reactTag)
{
    UnityPauseCommand();
}

RCT_EXPORT_METHOD(resume:(nonnull NSNumber *)reactTag)
{
    UnityResumeCommand();
}

@end

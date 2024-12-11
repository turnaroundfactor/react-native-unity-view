#include <csignal>
#import <UIKit/UIKit.h>
#import "UnityUtils.h"


// Hack to work around iOS SDK 4.3 linker problem
// we need at least one __TEXT, __const section entry in main application .o files
// to get this section emitted at right time and so avoid LC_ENCRYPTION_INFO size miscalculation
static const int constsection = 0;

bool unity_inited = false;

int g_argc;
char** g_argv;

void UnityInitTrampoline();

UnityFramework* ufw;

extern "C" void InitArgs(int argc, char* argv[])
{
    g_argc = argc;
    g_argv = argv;
}

extern "C" bool UnityIsInited()
{
    return unity_inited;
}

UnityFramework* UnityFrameworkLoad() {
    NSLog(@"UnityFrameworkLoad");
    NSString* bundlePath = nil;
    bundlePath = [[NSBundle mainBundle] bundlePath];
    bundlePath = [bundlePath stringByAppendingString: @"/Frameworks/UnityFramework.framework"];
     NSLog(@"bundlePath: %@", bundlePath);

    NSBundle* bundle = [NSBundle bundleWithPath: bundlePath];
    if ([bundle isLoaded] == false) {
        NSLog(@"bundle isLoaded is false");
        [bundle load];
    }else{
        NSLog(@"bundle isLoaded is true");
    }

    UnityFramework* ufw = [bundle.principalClass getInstance];
    return ufw;
}

extern "C" void InitUnity()
{
    NSLog(@"InitUnity start");
    if (unity_inited) {
        NSLog(@"unity_inited is true");
        return;
    }
    unity_inited = true;

    ufw = UnityFrameworkLoad();
    //setIsUnityReady(YES);

    [ufw setDataBundleId: "com.unity3d.framework"];
    [ufw frameworkWarmup: g_argc argv: g_argv];
}

extern "C" void UnityPostMessage(NSString* gameObject, NSString* methodName, NSString* message)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [ufw sendMessageToGOWithName:[gameObject UTF8String] functionName:[methodName UTF8String] message:[message UTF8String]];
    });
}

extern "C" void UnityPauseCommand()
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [ufw pause:true];
    });
}

extern "C" void UnityResumeCommand()
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [ufw pause:false];
    });
}

@implementation UnityUtils

static NSHashTable* mUnityEventListeners = [NSHashTable weakObjectsHashTable];
static BOOL _isUnityReady = NO;

+ (BOOL)isUnityReady
{
    NSLog(@"_isUnityReady: %s", _isUnityReady ? "true" : "false");
    return _isUnityReady;
}

//+ (BOOL) setIsUnityReady:(BOOL)value
//{
//    _isUnityReady = value;
//    return value;
//}

+ (void)handleAppStateDidChange:(NSNotification *)notification
{
    if (!_isUnityReady) {
        return;
    }
    UnityAppController* unityAppController = GetAppController();

    UIApplication* application = [UIApplication sharedApplication];

    if ([notification.name isEqualToString:UIApplicationWillResignActiveNotification]) {
        [unityAppController applicationWillResignActive:application];
    } else if ([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        [unityAppController applicationDidEnterBackground:application];
    } else if ([notification.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
        [unityAppController applicationWillEnterForeground:application];
    } else if ([notification.name isEqualToString:UIApplicationDidBecomeActiveNotification]) {
        [unityAppController applicationDidBecomeActive:application];
    } else if ([notification.name isEqualToString:UIApplicationWillTerminateNotification]) {
        [unityAppController applicationWillTerminate:application];
    } else if ([notification.name isEqualToString:UIApplicationDidReceiveMemoryWarningNotification]) {
        [unityAppController applicationDidReceiveMemoryWarning:application];
    }
}

+ (void)listenAppState
{
    for (NSString *name in @[UIApplicationDidBecomeActiveNotification,
                             UIApplicationDidEnterBackgroundNotification,
                             UIApplicationWillTerminateNotification,
                             UIApplicationWillResignActiveNotification,
                             UIApplicationWillEnterForegroundNotification,
                             UIApplicationDidReceiveMemoryWarningNotification]) {

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleAppStateDidChange:)
                                                     name:name
                                                   object:nil];
    }
}

+ (void)createPlayer:(void (^)(void))completed
{
    NSLog(@"Inside CreatePlayer");
    if (_isUnityReady) {
        NSLog(@"Unity PLayer is ready");
        completed();
        return;
    }

    [[NSNotificationCenter defaultCenter] addObserverForName:@"UnityReady" object:nil queue:[NSOperationQueue mainQueue]  usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"Unity PLayer is ready 2");
        _isUnityReady = YES;
        completed();
    }];

    if (UnityIsInited()) {
        NSLog(@"UnityIsInited");
        return;
    }
    else{
        NSLog(@"UnityIsInited NOT");
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"dispatch_get_main_queue()");
        UIApplication* application = [UIApplication sharedApplication];

        // Always keep RN window in top
        application.keyWindow.windowLevel = UIWindowLevelNormal + 1;
        NSLog(@"Before InitUnity");
        InitUnity();
        NSLog(@"After InitUnity");
        UnityAppController *controller = GetAppController();
        NSLog(@"after getappcontroller");
        [controller application:application didFinishLaunchingWithOptions:nil];
        [controller applicationDidBecomeActive:application];

        // Makes RN window key window to handle events
        [application.windows[1] makeKeyWindow];
        
        [UnityUtils listenAppState];
    });
}

@end

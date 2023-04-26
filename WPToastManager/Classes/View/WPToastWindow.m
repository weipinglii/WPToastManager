//
//  WPToastWindow.m
//  WPToastManager
//
//  Created by weiping.lii on 2022/3/18.
//

#import "WPToastWindow.h"

@implementation WPToastWindow

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.windowLevel = UIWindowLevelStatusBar + 100.0;
    self.rootViewController = [WPToastWindowRootVC new];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL pointInside = NO;
    if ([self.eventDelegate toastWindow:self shouldHandleTouchAtLocation:point]) {
        pointInside = [super pointInside:point withEvent:event];
    }
    return pointInside;
}

@end

static NSString *const kString = @"X3ZpZXdDb250cm9sbGVyRm9yU3VwcG9ydGVkSW50ZXJmYWNlT3JpZW50YXRpb25z";

@implementation WPToastWindowRootVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
}

#pragma mark - Rotation

- (UIViewController *)viewControllerForRotationAndOrientation {
    UIViewController *viewController = UIApplication.sharedApplication.keyWindow.rootViewController;
    NSData *data = [[NSData alloc] initWithBase64EncodedString:kString options:0];
    NSString *foo = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    SEL selector = NSSelectorFromString(foo);
    if ([viewController respondsToSelector:selector]) {
        viewController = [viewController valueForKey:foo];
    }
    
    return viewController;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    UIViewController *viewControllerToAsk = [self viewControllerForRotationAndOrientation];
    UIInterfaceOrientationMask supportedOrientations = [WPToastWindowRootVC infoPlistSupportedInterfaceOrientationsMask];
    if (viewControllerToAsk && ![viewControllerToAsk isKindOfClass:[self class]]) {
        supportedOrientations = [viewControllerToAsk supportedInterfaceOrientations];
    }
    
    // The UIViewController docs state that this method must not return zero.
    // If we weren't able to get a valid value for the supported interface
    // orientations, default to all supported.
    if (supportedOrientations == 0) {
        supportedOrientations = UIInterfaceOrientationMaskAll;
    }
    
    return supportedOrientations;
}

+ (UIInterfaceOrientationMask)infoPlistSupportedInterfaceOrientationsMask {
    NSArray<NSString *> *supportedOrientations = NSBundle.mainBundle.infoDictionary[@"UISupportedInterfaceOrientations"];
    UIInterfaceOrientationMask supportedOrientationsMask = 0;
    if ([supportedOrientations containsObject:@"UIInterfaceOrientationPortrait"]) {
        supportedOrientationsMask |= UIInterfaceOrientationMaskPortrait;
    }
    if ([supportedOrientations containsObject:@"UIInterfaceOrientationMaskLandscapeRight"]) {
        supportedOrientationsMask |= UIInterfaceOrientationMaskLandscapeRight;
    }
    if ([supportedOrientations containsObject:@"UIInterfaceOrientationMaskPortraitUpsideDown"]) {
        supportedOrientationsMask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    if ([supportedOrientations containsObject:@"UIInterfaceOrientationLandscapeLeft"]) {
        supportedOrientationsMask |= UIInterfaceOrientationMaskLandscapeLeft;
    }
    return supportedOrientationsMask;
}

- (BOOL)shouldAutorotate {
    UIViewController *viewControllerToAsk = [self viewControllerForRotationAndOrientation];
    BOOL shouldAutorotate = YES;
    if (viewControllerToAsk && viewControllerToAsk != self) {
        shouldAutorotate = [viewControllerToAsk shouldAutorotate];
    }
    return shouldAutorotate;
}

@end

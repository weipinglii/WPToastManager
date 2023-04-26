//
//  WPAbstractToast.m
//  WPToastManager
//
//  Created by weiping.lii on 2021/11/16.
//

#import "WPAbstractToast.h"
#import "WPEventToast.h"

@import Masonry;
@import UIKit;

@interface WPAbstractToast ()

@property (nonatomic, strong) NSTimer *dismissTimer;
@property (nonatomic, strong, readwrite) id<WPToastMessage> message;

@end

@implementation WPAbstractToast

+ (instancetype)toastForMessage:(id<WPToastMessage>)message {
    WPEventToast *toast = [[WPEventToast alloc] init];
    [toast bindViewModel:message];
    return toast;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self abstractToastInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self abstractToastInit];
    }
    return self;
}

- (void)abstractToastInit {
//    self.backgroundColor = [UIColor ] colorDynamicFromRGBA(0xffffff, 0.98, 0x121212, 0.98);
    self.layer.cornerRadius = 8;
//    self.layer.shadowColor = colorFromRGB(0x000000).CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.shadowOpacity = 0.1;
    self.layer.shadowRadius = 20.0;
    
    [self addGestureRecognizer:self.panGesture];
    [self addGestureRecognizer:self.tapGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)bindViewModel:(id<WPToastMessage>)message {
    self.message = message;
}

- (void)showInView:(UIView *)view {
    NSParameterAssert(view != nil);
    if (view == nil) {
        return;
    }
    
    [view addSubview:self];
    if (self.displayingAreaCustomizer != nil) {
        self.displayingAreaCustomizer(self, view);
    } else {
        if (@available(iOS 11.0, *)) {
            //  autolayout
            [self mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(view.mas_safeAreaLayoutGuideTop).priority(UILayoutPriorityDefaultHigh);
                make.top.greaterThanOrEqualTo(view).offset(28);
                make.centerX.equalTo(view);
                make.width.equalTo(view).offset(-16 * 2).priority(UILayoutPriorityRequired - 10);
                CGFloat maxWidth = MAX(CGRectGetHeight(UIScreen.mainScreen.bounds), CGRectGetWidth(UIScreen.mainScreen.bounds)) * 0.618;
                make.width.lessThanOrEqualTo(@(maxWidth));
            }];
        } else {
            NSAssert(NO, @"only support iOS >= 11.0");
        }
    }
    
    [view setNeedsLayout];
    [view layoutIfNeeded];
    
    CGFloat ty = -CGRectGetMaxY(self.frame);
    self.transform = CGAffineTransformMakeTranslation(0, ty);
    [self p_animateWithInitialVelocity:0 dismiss:NO];
}

- (void)dismiss {
    [self dismissAnimated:YES];
}

- (void)dismissAnimated:(BOOL)animated {
    if (self.dismissTimer.isValid) {
        [self.dismissTimer invalidate];
        if (animated) {
            [self p_animateWithInitialVelocity:0 dismiss:YES];
        } else {
            [self removeFromSuperview];
        }
    } else {
        //  being dismissed
    }
}

- (void)dismissAfter:(NSTimeInterval)delay {
    if (self.dismissTimer.isValid) {
        delay = MAX(0.1, delay);
        NSDate *newFireDate = [NSDate dateWithTimeIntervalSinceNow:delay];
        if ([newFireDate compare:self.dismissTimer.fireDate] == NSOrderedAscending) {
            self.dismissTimer.fireDate = newFireDate;
        }
    } else {
        // being dismissed
    }
}

- (void)p_animateWithInitialVelocity:(CGFloat)velocity dismiss:(BOOL)dismiss {
    CGFloat ty = fabs(self.transform.ty);
    CGFloat maxY = CGRectGetMaxY(self.frame);
    if (dismiss) {
        if (maxY <= 0) {
            [self removeFromSuperview];
        } else {
            CGFloat durationPercent = maxY/(maxY + ty);
            CGFloat velocityPercent = fabs(velocity)/maxY;
            
            [UIView animateWithDuration:0.5 * durationPercent
                                  delay:0
                 usingSpringWithDamping:0.9
                  initialSpringVelocity:velocityPercent
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                self.transform = CGAffineTransformTranslate(self.transform, 0, -maxY);
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
            }];
        }
    } else {
        CGFloat durationPercent = ty/(maxY + ty);
        CGFloat velocityPercent = fabs(velocity)/ty;
        
        [UIView animateWithDuration:0.5 * durationPercent
                              delay:0
             usingSpringWithDamping:0.9
              initialSpringVelocity:velocityPercent
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
}

- (void)loadMessagInfo {
    //  Override by subclass
}

- (NSTimeInterval)p_displayTime {
    return MAX(2.0, self.message.displayTime);
}

- (void)didMoveToWindow {
    if (self.windowCallback != nil) {
        self.windowCallback(self);
    }
    if (self.window != nil) {
        [self.dismissTimer invalidate];
        __weak typeof(self) weakSelf = self;
        self.dismissTimer = [NSTimer scheduledTimerWithTimeInterval:[self p_displayTime]
                                                            repeats:NO
                                                              block:^(NSTimer * _Nonnull timer) {
            __strong typeof(self) self = weakSelf;
            [self p_animateWithInitialVelocity:0 dismiss:YES];
        }];
    } else {
        [self.dismissTimer invalidate];
        self.dismissTimer = nil;
    }
}

#pragma mark -

- (void)onPanGR:(UIPanGestureRecognizer *)panGR {
    //  延迟timer触发时间
    self.dismissTimer.fireDate = [NSDate distantFuture];
    switch (panGR.state) {
        case UIGestureRecognizerStateBegan: break;
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [panGR translationInView:self.superview];
            self.transform = CGAffineTransformMakeTranslation(0, MIN(0, translation.y));
            break;
        }
        case UIGestureRecognizerStateEnded: {
            CGPoint velocity = [panGR velocityInView:self.superview];
            if (CGRectGetMinY(self.frame) < 0 || velocity.y < 0) {
                [self p_animateWithInitialVelocity:velocity.y dismiss:YES];
            } else {
                [self p_animateWithInitialVelocity:velocity.y dismiss:NO];
                //  重置展示计时
                self.dismissTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:[self p_displayTime]];
            }
            break;
        }
        default: {
            //  重置展示计时
            self.dismissTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:[self p_displayTime]];
            CGPoint velocity = [panGR velocityInView:self.superview];
            [self p_animateWithInitialVelocity:velocity.y dismiss:NO];
            break;
        }
    }
}

- (void)onTapGR:(UITapGestureRecognizer *)tapGR {
    NSURL *URL = self.message.schemeURL;
    if (URL != nil && [[UIApplication sharedApplication] canOpenURL:URL]) {
        [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];
    }
    
    if (self.message.clickAction) {
        self.message.clickAction(self.message);
    }
    
    [self dismiss];
}

- (void)onApplicationDidBecomeActive {
    if (self.dismissTimer.isValid) {
        self.dismissTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:[self p_displayTime]];
    }
}

- (void)onApplicationWillResignActive {
    if (self.dismissTimer.isValid) {
        self.dismissTimer.fireDate = [NSDate distantFuture];
    }
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGR:)];
    }
    return _panGesture;
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGR:)];
    }
    return _tapGesture;
}

@end


@implementation UIImage (wpUtil)

+ (UIImage *)wp_bundledImage:(NSString *)imageName {
    NSBundle *bundle = [NSBundle bundleForClass:[WPAbstractToast class]];
    NSString *path = [bundle pathForResource:@"WPToastManager" ofType:@"bundle"];
    NSBundle *imageBundle = [NSBundle bundleWithPath:path];
    return [UIImage imageNamed:imageName inBundle:imageBundle compatibleWithTraitCollection:nil];
}

@end

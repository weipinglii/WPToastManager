//
//  WPToastCenter.m
//  WPToastManager
//
//  Created by weiping.lii on 2021/11/15.
//

#import "WPToastCenter.h"
#import "WPAbstractToast.h"
#import <objc/runtime.h>
#import "WPToastWindow.h"

@interface WPToastCenter () <WPToastWindowDelegate>

@property (nonatomic, strong) NSMutableArray<id<WPToastMessage>> *messageQueue;
@property (nonatomic, weak) WPAbstractToast *currentToast;
@property (nonatomic, strong) WPToastWindow *window;
@property (nonatomic, strong) NSTimer *timer;
/// 上个 toast 显示时间
@property (nonatomic, strong) NSDate *lastFireDate;
@property (nonatomic, copy) NSDictionary<NSString *, WPToastControlInfo *> *frequencyControlInfo;

@end

char kFrequencyControlInfoKey;
static NSString *kControlInfoCacheVersionKey = @"version";
static NSString *kControlInfoCacheDataKey = @"data";
static NSString *kControlInfoCacheFileName = @"control_info.dat";

@implementation WPToastCenter

+ (instancetype)shared {
    static WPToastCenter * _manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
        _manager.lastFireDate = [NSDate dateWithTimeIntervalSinceNow:NSIntegerMin];
        [[NSNotificationCenter defaultCenter] addObserver:_manager selector:@selector(onApplicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:_manager selector:@selector(onApplicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        _manager.acceptUnknownMessageType = YES;
        [_manager p_loadCachedFrequencyControlInfo];
    });
    return _manager;
}

- (void)pushMessage:(id<WPToastMessage>)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self p_pushMessage:message];
    });
}

- (void)removeCurrentMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.currentToast != nil) {
            [self.currentToast dismiss];
        }
    });
}

- (void)removeMessage:(id<WPToastMessage>)message {
    if (message == nil) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.currentToast.message isEqual:message]) {
            [self.currentToast dismiss];
        }
        
        if (self.timer.isValid && [self.timer.userInfo isEqual:message]) {
            [self.timer invalidate];
            self.timer = nil;
        }
        
        if ([self.messageQueue containsObject:message]) {
            [self.messageQueue removeObject:message];
            //  生命周期回调
            [self p_callbackForMessage:message event:WPToastMessageDiscarded eventDesc:@"removed by external api"];
        }
        
        [self p_updateTimerForNextToast];
    });
}

- (id<WPToastMessage>)currentToastMesage {
    return self.currentToast.message;
}

- (WPToastControlInfo *)controlInfoForMessageType:(NSString *)type {
    if (type == nil) {
        return nil;
    }
    return self.frequencyControlInfo[type];
}

- (void)loadControlInfo:(NSArray<WPToastControlInfo *> *)controlInfo {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (WPToastControlInfo *obj in controlInfo) {
        NSAssert([obj isKindOfClass:[WPToastControlInfo class]], @"invalid control info");
        if ([obj isKindOfClass:[WPToastControlInfo class]]) {
            dict[obj.type] = obj;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.frequencyControlInfo = [dict copy];
        [self p_cacheControlInfo];
    });
}

#pragma mark - Private

- (BOOL)validateMessage:(id<WPToastMessage>)message {
    
    BOOL check = NO;
    
    do {
        if (message == nil || ![message conformsToProtocol:@protocol(WPToastMessage)]) {
            //  参数类型错误
            NSAssert(NO, @"message does not conforms to WPToastMessage protocol");
            break;
        }
        
        if (![message respondsToSelector:@selector(lifeCycleCallback)] ||
            ![message respondsToSelector:@selector(customToastClass)] ||
            ![message respondsToSelector:@selector(displayTime)] ||
            ![message respondsToSelector:@selector(type)])
        {
            NSAssert(NO, @"message does not implement all protocol methods");
            break;
        }
        Class customToastClass = nil;
        if ([message respondsToSelector:@selector(customToastClass)]) {
            customToastClass = [message customToastClass];
        }
        
        if (customToastClass != nil) {
            if (![customToastClass isSubclassOfClass:[WPAbstractToast class]]) {
                break;
            }
            //  自定义toast视图，不检查 optional 协议方法
            check = YES;
            break;
        }
        
        //  未指定自定义样式将使用标准 toast 视图
        //  检查所有 optional 协议方法
        if (![message respondsToSelector:@selector(title)] ||
            ![message respondsToSelector:@selector(subtitle)] ||
            ![message respondsToSelector:@selector(imageURL)] ||
            ![message respondsToSelector:@selector(placeholder)] ||
            ![message respondsToSelector:@selector(schemeURL)] ||
            ![message respondsToSelector:@selector(clickAction)])
        {
            NSAssert(NO, @"message does not implement all protocol methods");
            break;
        }
        
        check = YES;
    } while (0);
    
    return check;
}

- (void)p_pushMessage:(id<WPToastMessage>)message {
    NSParameterAssert(message != nil && [message conformsToProtocol:@protocol(WPToastMessage)]);
    //  生命周期回调
    [self p_callbackForMessage:message event:WPToastMessageReceived eventDesc:@"message received"];
    BOOL check = YES;
    do {
        //  查询频控数据
        check = [self p_bindControlInfoForMessage:message];
        
        if (check == NO) {
            //  生命周期回调
            [self p_callbackForMessage:message event:WPToastMessageDiscarded eventDesc:@"control info not found"];
            break;
        }
        
        if (![self validateMessage:message]) {
            //  数据校验
            check = NO;
            //  生命周期回调
            [self p_callbackForMessage:message event:WPToastMessageDiscarded eventDesc:@"message data validation failed"];
            break;
        }
        
    } while (0);
    
    if (check) {
        //  进入队列
        [self.messageQueue addObject:message];
        //  生命周期回调
        [self p_callbackForMessage:message event:WPToastMessageQueued eventDesc:@"did enter message queue"];
        
        [self p_updateTimerForNextToast];
    }
}

- (id<WPToastMessage>)p_findNextToastMessage {
    id<WPToastMessage> nextMessage = [self.messageQueue firstObject];
    if (nextMessage == nil) {
        //  当前队列已全部弹出
        return nextMessage;
    }
    WPToastControlInfo *nextControlInfo = [self p_getBindedControlInfoForMessage:nextMessage];
    for (id<WPToastMessage> message in self.messageQueue) {
        WPToastControlInfo *controlInfo = [self p_getBindedControlInfoForMessage:message];
        if (controlInfo.priority > nextControlInfo.priority) {
            nextMessage = message;
            nextControlInfo = controlInfo;
        }
    }
    
    //  确认过期时间 - 用时间戳判断避免代码执行本身的耗时导致消息过期和一些边界情况
    NSTimeInterval ts1 = [nextControlInfo.expirationDate timeIntervalSince1970];
    NSTimeInterval ts2 = [self.lastFireDate timeIntervalSince1970] + nextControlInfo.interval;
    BOOL valid = ABS(ts1 - ts2) < 0.1 || ts1 > ts2;
    if (!valid) {
        [self.messageQueue removeObject:nextMessage];
        //  生命周期回调
        [self p_callbackForMessage:nextMessage event:WPToastMessageExpired eventDesc:@"message expired"];
        return [self p_findNextToastMessage];
    } else {
        return nextMessage;
    }
}

- (void)p_updateTimerForNextToast {
    id<WPToastMessage> nextMessage = [self p_findNextToastMessage];
    if (nextMessage == nil) {
        return;
    }
    
    if (self.timer.isValid &&
        self.timer.userInfo != nil &&
        [nextMessage isEqual:self.timer.userInfo])
    {
        //  下一个消息不需要变更
        return;
    }
    
    WPToastControlInfo *controlInfo = [self p_getBindedControlInfoForMessage:nextMessage];
    NSDate *fireDate = nil;
    NSTimeInterval interval = controlInfo.interval;
    if (self.currentToastMesage) {
        WPToastControlInfo *currentControlInfo = [self p_getBindedControlInfoForMessage:self.currentToastMesage];
        //  如果新消息的优先级低于正在展示的消息，那么在当前消息展示结束之后才展示新消息
        if (controlInfo.priority < currentControlInfo.priority) {
            interval = MAX(controlInfo.interval, self.currentToastMesage.displayTime + 1);
        }
    }
    fireDate = [self.lastFireDate dateByAddingTimeInterval:interval];
    //  是否可以直接展示
    [self.timer invalidate];
    if ([fireDate compare:[NSDate date]] == NSOrderedAscending) {
        //  仍然设置一个fireDate 为 distantFuture 的 timer，通过 timer 持有的 userInfo（nextMessage）统一处理逻辑
        self.timer = [[NSTimer alloc] initWithFireDate:[NSDate distantFuture]
                                              interval:0
                                                target:self
                                              selector:@selector(onTimerFired:)
                                              userInfo:nextMessage
                                               repeats:NO];
        [self p_popMessage:nextMessage];
    } else {
        self.timer = [[NSTimer alloc] initWithFireDate:fireDate
                                              interval:0
                                                target:self
                                              selector:@selector(onTimerFired:)
                                              userInfo:nextMessage
                                               repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

- (void)onTimerFired:(NSTimer *)timer {
    id<WPToastMessage>message = timer.userInfo;
    [self p_popMessage:message];
}

- (void)p_popMessage:(id<WPToastMessage>)message {
    //  是否展示的回调
    if ([message respondsToSelector:@selector(shouldDisplayCallback)] &&
        message.shouldDisplayCallback != nil)
    {
        BOOL display = message.shouldDisplayCallback(message);
        if (display == NO) {
            //  忽略这条消息，并尝试展示下一条消息
            //  生命周期回调
            [self p_callbackForMessage:message event:WPToastMessageDiscarded eventDesc:@"discarded caused by shouldDisplayCallback"];
            [self.messageQueue removeObject:message];
            [self p_updateTimerForNextToast];
            return;
        }
    }
    //  开始弹出消息 - 记录弹出时间点
    self.lastFireDate = [NSDate date];

    //  有消息正在显示的处理逻辑
    if (self.currentToast != nil && self.currentToast.window) {
        self.currentToast.windowCallback = ^(WPAbstractToast *toast) {
            if (toast.window) {
                //  生命周期回调
                [self p_callbackForMessage:message event:WPToastMessageDisplayed eventDesc:@"toast displayed"];
            } else {
                //  消失
                [self p_callbackForMessage:message event:WPToastMessageDismissed eventDesc:@"toast dismissed by new arrival"];
            }
        };
        [self.currentToast dismiss];
    }
    
    //  创建toast
    WPAbstractToast *toast = nil;
    
    Class toastClass = nil;
    if ([message respondsToSelector:@selector(customToastClass)]) {
        toastClass = message.customToastClass;
    }
    
    if (toastClass == nil) {
        toast = [WPAbstractToast toastForMessage:message];
    } else {
        NSAssert([toastClass isSubclassOfClass:[WPAbstractToast class]], @"invalid custom toast class");
        toast = [[toastClass alloc] init];
    }
    //  绑定数据
    [toast bindViewModel:message];
    toast.controlInfo = [self p_getBindedControlInfoForMessage:message];
    toast.windowCallback = ^(WPAbstractToast *toast) {
        if (toast.window) {
            //  展示
            //  生命周期回调
            [self p_callbackForMessage:message event:WPToastMessageDisplayed eventDesc:@"toast displayed"];
        } else {
            //  消失
            [self p_callbackForMessage:message event:WPToastMessageDismissed eventDesc:@"toast dismissed when display time ended"];
            self.window.hidden = YES;
        }
    };
    self.window.hidden = NO;
    [toast showInView:self.window.rootViewController.view];
    
    //  移出队列
    self.currentToast = toast;
    [self.messageQueue removeObject:message];
    
    //  为下一个消息更新timer
    [self p_updateTimerForNextToast];
}

- (void)p_loadCachedFrequencyControlInfo {
    NSArray *dataArr = @[[WPToastControlInfo new]];
    do {
        NSURL *libraryPath = [[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask].firstObject;
        if (!libraryPath) break;
        
        NSURL *fileURL = [libraryPath URLByAppendingPathComponent:kControlInfoCacheFileName];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:fileURL.absoluteString]) break;
        
        NSError *error = nil;
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfURL:fileURL error:&error];
        if (error) {
            NSLog(@"%@", error);
            break;
        }
        NSString *version = [dict objectForKey:kControlInfoCacheVersionKey];
        
        if (![version isEqual:WPToastControlInfo.version]) {
            [[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error];
            break;
        }
        NSArray *arr = dict[kControlInfoCacheDataKey];
        if ([arr isKindOfClass:[NSArray class]] && arr.count > 0) {
            dataArr = arr;
        }
        
    } while (0);
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (WPToastControlInfo *obj in dataArr) {
        NSAssert([obj isKindOfClass:[WPToastControlInfo class]], @"invalid control info");
        if ([obj isKindOfClass:[WPToastControlInfo class]]) {
            dict[obj.type] = obj;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.frequencyControlInfo = [dict copy];
    });
}

- (void)p_cacheControlInfo {
    do {
        NSArray *objects = self.frequencyControlInfo.allValues;
        
        NSURL *libraryPath = [[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask].firstObject;
        if (!libraryPath) break;
        
        NSURL *fileURL = [libraryPath URLByAppendingPathComponent:kControlInfoCacheFileName];
        NSDictionary *dict = @{
            kControlInfoCacheVersionKey : WPToastControlInfo.version,
            kControlInfoCacheDataKey : objects
        };
        NSError *error = nil;
        [dict writeToURL:fileURL error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
    } while (0);
}

- (BOOL)p_bindControlInfoForMessage:(id<WPToastMessage>)message {
    NSParameterAssert(message != nil && message.type != nil);
    WPToastControlInfo *controlInfo = nil;
    if (message.type.length > 0) {
        controlInfo = self.frequencyControlInfo[message.type];
    }
    if (!self.acceptUnknownMessageType) {
        return NO;
    }
    if (controlInfo == nil) {
        controlInfo = self.frequencyControlInfo[@"default"];
    }
    
    if (controlInfo == nil) {
        controlInfo = [WPToastControlInfo new];
    }
    controlInfo = [controlInfo copy];
    controlInfo.receiveAt = [NSDate date];
    objc_setAssociatedObject(message, &kFrequencyControlInfoKey, controlInfo, OBJC_ASSOCIATION_RETAIN);
    return YES;
}

- (WPToastControlInfo *)p_getBindedControlInfoForMessage:(id<WPToastMessage>)message {
    NSParameterAssert(message != nil);
    WPToastControlInfo *controlInfo = objc_getAssociatedObject(message, &kFrequencyControlInfoKey);
    NSAssert(controlInfo != nil, @"control info should be binded before message is binded in -[WPToastManager pushMessage:]");
    return controlInfo;
}

#pragma mark - Notifications

- (void)onApplicationWillResignActive {
    if (self.timer.isValid) {
        self.timer.fireDate = [NSDate distantFuture];
    }
}

- (void)onApplicationDidBecomeActive {
    if (self.timer.isValid) {
        id<WPToastMessage> message = self.timer.userInfo;
        NSDate *date1 = [NSDate dateWithTimeIntervalSinceNow:3];
        WPToastControlInfo *controlInfo = [self p_getBindedControlInfoForMessage:message];
        NSDate *date2 = [NSDate dateWithTimeInterval:controlInfo.interval sinceDate:self.lastFireDate];
        self.timer.fireDate = ([date1 compare:date2] == NSOrderedDescending) ? date1 : date2;
        //  最早在进入前台3秒后再弹出
    }
}

- (void)p_callbackForMessage:(id<WPToastMessage>)message
                      event:(WPToastMessageLifeCycle)event
                   eventDesc:(NSString *_Nullable)eventDesc
{
    if ([self.delegate respondsToSelector:@selector(toastCenter:callbackForMessage:lifeCycleEvent:eventDesc:)]) {
        [self.delegate toastCenter:self callbackForMessage:message lifeCycleEvent:event eventDesc:eventDesc];
    }
    if (message.lifeCycleCallback) {
        message.lifeCycleCallback(message, event);
    }
}

#pragma mark - WPToastWindowDelegate

- (BOOL)toastWindow:(WPToastWindow *)window shouldHandleTouchAtLocation:(CGPoint)location {
    if (self.currentToast == nil || self.currentToast.window == nil) {
        return NO;
    }
    CGRect rect = [self.currentToast convertRect:self.currentToast.bounds toView:window];
    return CGRectContainsPoint(rect, location);
}

#pragma mark -

- (NSMutableArray<id<WPToastMessage>> *)messageQueue {
    if (!_messageQueue) {
        _messageQueue = (NSMutableArray<id<WPToastMessage>> *)[NSMutableArray array];
    }
    return _messageQueue;
}

- (WPToastWindow *)window {
    if (!_window) {
        WPToastWindow *view = [[WPToastWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        view.hidden = YES;
        view.eventDelegate = self;
        _window = view;
    }
    if (@available(iOS 13.0, *)) {
        if (_window.windowScene == nil) {
            for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if ([scene isKindOfClass:[UIWindowScene class]]) {
                    _window.windowScene = scene;
                    break;
                }
            }
        }
    }
    return _window;
}

@end

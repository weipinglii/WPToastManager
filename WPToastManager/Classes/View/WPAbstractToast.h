//
//  WPAbstractToast.h
//  WPToastManager
//
//  Created by weiping.lii on 2021/11/16.
//

#import <UIKit/UIKit.h>
#import "WPToastMessage.h"
#import "WPToastControlInfo.h"

NS_ASSUME_NONNULL_BEGIN

/// 抽象基类，提供工厂方法
/// 实现基本的动画/回调/手势处理逻辑，不直接使用 ！！！
/// 子类继承
@interface WPAbstractToast : UIView
/// 数据模型
@property (nonatomic, readonly) id<WPToastMessage> message;
/// 滑动手势
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
/// 点击手势
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
/// 从window上添加/移除的回调 - 由 WPToastManager 设置用于管理消息队列
@property (nonatomic, copy, nullable) void (^windowCallback)(WPAbstractToast *toast);
/// 自定义在屏幕上的显示区域 - container 为 WPToastManager 内部的window
/// 如果需要自定义显示区域尽量使用autolayout，规避适配问题
@property (nonatomic, copy, nullable) void (^displayingAreaCustomizer)(WPAbstractToast *toast, UIView *container);

/// 工厂方法， 根据传入的model初始化不同样式的标准UI
+ (instancetype _Nullable)toastForMessage:(id<WPToastMessage>)message;

/// 绑定WPToastMessage 数据
/// ！！！如果自定义UI必须重写此方法设置UI数据
/// @param message 数据模型
- (void)bindViewModel:(id<WPToastMessage>)message NS_REQUIRES_SUPER;

/// WPToastManager 展示时调用
/// @param view WPToastManager 内部的一个window
- (void)showInView:(UIView *)view;

/// 移除 toast
- (void)dismiss;
- (void)dismissAnimated:(BOOL)animated;

/// 一定时间后移除 toast
/// @param delay 延迟时长
- (void)dismissAfter:(NSTimeInterval)delay;

@end

@interface UIImage (wpUtil)

+ (UIImage *)wp_bundledImage:(NSString *)imageName;

@end

NS_ASSUME_NONNULL_END

//
//  WPToastMessage.h
//  WPToastManager
//
//  Created by weiping.lii on 2021/11/18.
//

#import <Foundation/Foundation.h>
#import "WPToastControlInfo.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WPToastMessageLifeCycle) {
    WPToastMessageReceived,
    WPToastMessageQueued,
    WPToastMessageDisplayed,
    WPToastMessageDismissed,
    WPToastMessageDiscarded,
    WPToastMessageExpired,
};

typedef void (^WPToastClickAction)(id messageObj);
typedef void (^WPToastLifeCycleCallback)(id messageObj, WPToastMessageLifeCycle event);
typedef BOOL (^WPToastshouldDisplayCallack)(id messageObj);

@protocol WPToastMessage <NSObject>
/// 消息类型
- (NSString *)type;

- (WPToastLifeCycleCallback _Nullable)lifeCycleCallback;
- (NSTimeInterval)displayTime;

- (void)setControlInfo:(WPToastControlInfo *)controlInfo;
- (WPToastControlInfo *)controlInfo;

/// compare priority, used to sort message in WPToastCenter
/// - Parameter message: other message
- (NSComparisonResult)compare:(id<WPToastMessage>)message;

@optional;

- (WPToastshouldDisplayCallack _Nullable)shouldDisplayCallback;

/// 当指定toast子类（非标准toast）不需要实现下列方法
/// 反之，使用标准toast视图需要实现下列方法
- (Class _Nullable)customToastClass;

- (NSString *_Nullable)title;
- (NSString *_Nullable)subtitle;
- (NSURL *_Nullable)imageURL;
- (UIImage *_Nullable)placeholder;
- (NSURL *_Nullable)schemeURL;
- (WPToastClickAction _Nullable)clickAction;

@end

@interface WPToastMessage : NSObject <WPToastMessage>
/// 任务生命周期的回调
@property (nonatomic, copy, nullable) WPToastLifeCycleCallback lifeCycleCallback;
/// 显示时长 3 second by default
@property (nonatomic, assign) NSTimeInterval displayTime;

@property (nonatomic, strong) WPToastControlInfo *controlInfo;

/// 在即将显示前调用，返回 YES 展示， NO 忽略这条数据
@property (nonatomic, copy, nullable) WPToastshouldDisplayCallack shouldDisplayCallback;
/// 消息类型 (业务类型，对应到具体的频控规则)
@property (nonatomic, copy) NSString *type;
/// 自定义 toast 的类
@property (nonatomic, strong, nullable) Class customToastClass;

/// 主标题
@property (nonatomic, strong, nullable) NSString *title;
/// 副标题
@property (nonatomic, strong, nullable) NSString *subtitle;
/// 图片地址
@property (nonatomic, strong, nullable) NSURL *imageURL;
/// 默认图片
@property (nonatomic, strong, nullable) UIImage *placeholder;
/// URL跳转
@property (nonatomic, strong, nullable) NSURL *schemeURL;
/// 点击事件 - 会和 schemeURL 同时触发
@property (nonatomic, copy, nullable) WPToastClickAction clickAction;

@end

NS_ASSUME_NONNULL_END

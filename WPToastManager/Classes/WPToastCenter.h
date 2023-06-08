//
//  WPToastCenter.h
//  WPToastManager
//
//  Created by weiping.lii on 2021/11/15.
//

#import <Foundation/Foundation.h>
#import "WPToastMessage.h"
#import "WPToastControlInfo.h"

NS_ASSUME_NONNULL_BEGIN

@class WPToastCenter;

@protocol WPToastEventDelegate <NSObject>

@optional
- (void)toastCenter:(WPToastCenter *)manager callbackForMessage:(id<WPToastMessage>)message lifeCycleEvent:(WPToastMessageLifeCycle)event eventDesc:(NSString *_Nullable)eventDesc;

@end

@interface WPToastCenter : NSObject

/// 用来做全局的事件处理，比如日志或通用埋点
@property (nonatomic, weak) id<WPToastEventDelegate> delegate;

/// 单例
@property (class, readonly) WPToastCenter *shared;

/// 是否展示未知业务类型的消息
/// default: NO
@property (nonatomic, assign) BOOL acceptUnknownMessageType;

/// 根据当前队列情况展示 toast 或 开始排队
/// @param message 数据 model
- (void)pushMessage:(id<WPToastMessage>)message;

/// 移除当前 toast
- (void)removeCurrentMessage;

/// 根据 model 移除当前 toast 或者移除队列
/// @param message 数据 model
- (void)removeMessage:(id<WPToastMessage>)message;

/// 设置频控规则
- (void)loadControlInfo:(NSArray<WPToastControlInfo *> *)controlInfo;

/// 当前的toast对象
- (id<WPToastMessage> _Nullable)currentToastMesage;

/// 根据业务类型获取频控信息
/// @param type 业务类型
- (WPToastControlInfo *_Nullable)controlInfoForMessageType:(NSString *)type;

@end

NS_ASSUME_NONNULL_END

//
//  WPToastControlInfo.h
//  WPToastManager
//
//  Created by weiping.lii on 2021/12/7.
//

#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface WPToastControlInfo : NSObject <YYModel, NSCopying>
/// 消息类型
@property (nonatomic, copy) NSString *type;
/// 间隔时间
@property (nonatomic, assign) NSTimeInterval interval;
/// 过期时间 收到消息后超过这个时间没有展示可以丢弃
@property (nonatomic, assign) NSTimeInterval expiration;
/// 优先级
@property (nonatomic, assign) NSInteger priority;
/// 接收消息的时间 - WPToastManager 设置
@property (nonatomic, strong, nullable) NSDate *receiveAt;
/// 过期时间
@property (nonatomic, readonly) NSDate *expirationDate;
/// 缓存数据版本控制
@property (class, readonly) NSString *version;

@end

NS_ASSUME_NONNULL_END

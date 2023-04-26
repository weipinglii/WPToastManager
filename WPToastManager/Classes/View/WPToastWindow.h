//
//  WPToastWindow.h
//  WPToastManager
//
//  Created by weiping.lii on 2022/3/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class WPToastWindow;

@protocol WPToastWindowDelegate <NSObject>

- (BOOL)toastWindow:(WPToastWindow *)window shouldHandleTouchAtLocation:(CGPoint)location;

@end

@interface WPToastWindow : UIWindow

@property (nonatomic, weak) id <WPToastWindowDelegate> eventDelegate;

@end

@interface WPToastWindowRootVC : UIViewController

@end

NS_ASSUME_NONNULL_END

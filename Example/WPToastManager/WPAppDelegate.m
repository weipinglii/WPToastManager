//
//  WPAppDelegate.m
//  WPToastManager
//
//  Created by weiping.lii@icloud.com on 04/18/2023.
//  Copyright (c) 2023 weiping.lii@icloud.com. All rights reserved.
//

#import "WPAppDelegate.h"
@import WPToastManager;

@implementation WPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    WPToastMessage *message = [[WPToastMessage alloc] init];
    message.title = @"open URL";
    message.subtitle = url.absoluteString;
    message.type = @"debug2";
    message.imageURL = [NSURL URLWithString:@"https://bpic.588ku.com/element_origin_min_pic/00/92/57/9856f2293341d6f.jpg"];
    [WPToastCenter.shared pushMessage:message];
    return YES;
}

@end

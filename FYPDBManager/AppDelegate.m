//
//  AppDelegate.m
//  FYPDBManager
//
//  Created by 凤云鹏 on 2017/5/14.
//  Copyright © 2017年 FYP. All rights reserved.
//

#import "AppDelegate.h"
#import "FYPDBManager.h"


/// Document dir
#define APP_PATH_DOCUMENT	 [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
/// 本地主数据库名称
#define LOCAL_MAIN_DB_NAME      @"fypdb.sqlite"
/// 本地主数据库完整路径
#define LOCAL_MAIN_DB_PATH      [APP_PATH_DOCUMENT stringByAppendingPathComponent:LOCAL_MAIN_DB_NAME]

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    BOOL checkResult = [[FYPDBManager sharedFYPDBBase] checkDatabase:LOCAL_MAIN_DB_PATH lastVersion:[FYPDBManager sharedFYPDBBase].dbVersion];
    if (!checkResult) {
        NSLog(@"check db fail.");
        
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"数据库初始化失败，不能继续加载，请彻底关闭程序后再次尝试，或者联系系统管理员。"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil, nil];
        [alertview show];
        return NO;
    }
    else {
        NSLog(@"check db success.");
    }

    
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end

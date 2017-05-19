//
//  FYPDBManager.h
//  FYPDBManager
//
//  Created by 凤云鹏 on 2017/5/16.
//  Copyright © 2017年 FYP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FYPDBBase.h"

//最新版本号
#define DBVERSION  1

@class User;
@interface FYPDBManager : FYPDBBase


/** 最新版本号 */
@property (nonatomic, readonly, assign) int dbVersion;

/**
 @brief 插入用户数据
 */
- (void)insertUser:(User *)user;

/**
 获取所有用户数据
 */
- (NSArray<User *> *)getAllUser;

/**
  根据userID删除用户数据
 */
- (void)deleteUserForUserID:(NSString *)userID;
@end

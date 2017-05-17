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

@interface FYPDBManager : FYPDBBase


/** 最新版本号 */
@property (nonatomic, readonly, assign) int dbVersion;

/**
 @brief 插入消息数据
 */
- (void)insertMessage:(NSDictionary *)message;
/**
 获取所有数据
 */
- (NSArray<NSDictionary *> *)getAllMessage;
@end

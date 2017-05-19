//
//  User.h
//  FYPDBManager
//
//  Created by 凤云鹏 on 2017/5/19.
//  Copyright © 2017年 FYP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject


/** 用户ID */
@property (nonatomic,copy) NSString *UserID;

/** 登陆ID */
@property (nonatomic,copy) NSString *LoginID;

/** 登录密码 */
@property (nonatomic,copy) NSString *loginPassword;

/** 用户名 */
@property (nonatomic,copy) NSString *UserName;

/** 年龄 */
@property (nonatomic,copy) NSNumber *Age;

/** 简介 */
@property (nonatomic,copy) NSString *Title;



/**
 根据字典初始化对象
 */
- (id)initWithDictionary:(NSDictionary *)dic;
/**
 类方法：根据字典初始化对象
 */
+ (id)feedWithDictionary:(NSDictionary *)dic;

@end

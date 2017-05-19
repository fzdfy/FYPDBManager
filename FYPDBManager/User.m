//
//  User.m
//  FYPDBManager
//
//  Created by 凤云鹏 on 2017/5/19.
//  Copyright © 2017年 FYP. All rights reserved.
//

#import "User.h"

@implementation User

/**
 根据字典初始化对象
 */
- (id)initWithDictionary:(NSDictionary *)dic
{
    if (self=[super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}
/**
 类方法：根据字典初始化对象
 */
+ (id)feedWithDictionary:(NSDictionary *)dic
{
    return [[self alloc] initWithDictionary:dic];
}
@end

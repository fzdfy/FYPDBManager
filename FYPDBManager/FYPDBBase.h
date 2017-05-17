//
//  FYPDBBase.h
//  FYPDBManager
//
//  Created by 凤云鹏 on 2017/5/16.
//  Copyright © 2017年 FYP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "FMDB.h"

@interface FYPDBBase : NSObject
singleton_h(FYPDBBase)

//数据库队列
@property (nonatomic, strong) FMDatabaseQueue *queue;
@property (nonatomic, strong) FMDatabase *db;

/** 查数据库 */
- (BOOL)checkDatabase:(NSString*)databaseName lastVersion:(int)lastVersion;

/** 升级数据库 */
- (BOOL)onUpgrade:(FMDatabase *)db oldVersion:(int)oldVersion lastVersion:(int)lastVersion;

/** 事务操作 */
-(void)inTransaction:(BOOL (^_Nonnull)())block;
@end

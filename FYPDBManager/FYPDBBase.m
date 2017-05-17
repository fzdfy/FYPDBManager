//
//  FYPDBBase.m
//  FYPDBManager
//
//  Created by 凤云鹏 on 2017/5/16.
//  Copyright © 2017年 FYP. All rights reserved.
//

#import "FYPDBBase.h"
#import "FMDB.h"

@interface FYPDBBase ()


@property (nonatomic, assign) BOOL inTransaction;
@end



@implementation FYPDBBase
singleton_m(FYPDBBase)


//事务操作
-(void)inTransaction:(BOOL (^_Nonnull)())block{
    NSAssert(block, @"block is nil!");
    [self executeDB:^(FMDatabase * _Nonnull db) {
        _inTransaction = db.inTransaction;
        if (!_inTransaction) {
            _inTransaction = [db beginTransaction];
        }
        BOOL isCommit = NO;
        isCommit = block();
        if (_inTransaction){
            if (isCommit) {
                [db commit];
            }else {
                [db rollback];
            }
            _inTransaction = NO;
        }
    }];
}
/**
 为了对象层的事物操作而封装的函数.
 */
-(void)executeDB:(void (^_Nonnull)(FMDatabase *_Nonnull db))block{
    NSAssert(block, @"block is nil!");
    //[self.threadLock lock];//加锁
    
    if (_db){//为了事务操作防止死锁而设置.
        block(_db);
        return;
    }
    __weak typeof(self) BGSelf = self;
    [self.queue inDatabase:^(FMDatabase *db) {
        BGSelf.db = db;
        block(db);
        BGSelf.db = nil;
    }];
    
    //[self.threadLock unlock];//解锁
}
/**
 检查数据库
 
 @param databaseName 数据库地址
 @param lastVersion 数据库最新版本号
 @return 成功/失败
 */
- (BOOL)checkDatabase:(NSString*)databaseName lastVersion:(int)lastVersion
{
    if (!databaseName) {
        NSAssert1(0, @"db path and name can't be empty (%@)", databaseName);
        @throw [NSException exceptionWithName:@"Database name error" reason:@"Database name and path can not be empty." userInfo:nil];
        return NO;
    }
    if (lastVersion < 1) {
        NSAssert1(0, @"The database version number cannot be less than 1. (%d)", lastVersion);
        @throw [NSException exceptionWithName:@"Database version error" reason:@"The database version number cannot be less than 1." userInfo:nil];
        return NO;
    }
    
    self.db = [FMDatabase databaseWithPath:databaseName];
    @try {
        if (![_db open]) {
            //[db release];
            //NSLog(@"db open fail");
            NSAssert1(0, @"db open fail (%@)", databaseName);
            return NO;
        }
        //查出当前数据库版本
        FMResultSet *rs = [_db executeQuery:@"PRAGMA user_version;"];
        int oldVersion = -1;
        if ([rs next])
        {
            oldVersion = [rs intForColumnIndex:0];
        }
        [rs close];
        
        if (oldVersion <= 0) { //表示第一次创建数据库
            [_db beginTransaction];//开始事务
            BOOL rev = [self onCreate:_db];
            if (rev) {
                rev = [_db executeUpdate:[NSString stringWithFormat:@"PRAGMA user_version = %d", lastVersion]];
                if (rev)
                [_db commit];
                else {
                    NSLog(@">>> db exec fail: %@", [_db lastError]);
                    [_db rollback];
                }
            }
            else {
                [_db rollback];
                NSLog(@">>> db exec fail: %@", [_db lastError]);
            }
            return rev;
        }
        else { //表示已经创建了库表，接下来走onUpgrade等，由开发者在子类中决定如何升级或降级库表结构
            
            if (lastVersion > oldVersion){ //新版本号大于旧版本号则执行onUpgrade里的方法
                //执行用户的更新代码
                [_db beginTransaction];
                BOOL rev = [self onUpgrade:self.db oldVersion:oldVersion lastVersion:lastVersion];
                if (rev) {
                    rev = [_db executeUpdate:[NSString stringWithFormat:@"PRAGMA user_version = %d", lastVersion]];
                    if (rev)
                    [_db commit];
                    else {
                        [_db rollback];
                        NSLog(@">>> db exec fail: %@", [_db lastError]);
                    }
                }
                else {
                    [_db rollback];
                    NSLog(@">>> db exec fail: %@", [_db lastError]);
                }
                //
                return rev;
            }else
            {
                return YES;
            }
        }
    }
    @catch (NSException *ex) {
        
        NSAssert1(0, @"Exception: %@", ex.reason);
        
    }
    @finally {
        [self.db close];
        
    }
    return NO;
}


/**
 * 创建数据库时的方法。子类需要覆盖该方法，实现创建数据库时的代码
 *
 * @param db FMDB的数据库对象
 * @return YES=成功，NO=失败
 */
- (BOOL)onCreate:(FMDatabase *)db {
    return YES;
}

/**
 * 数据库版本增加时的方法。子类需要覆盖该方法，实现数据库版本增加时的代码
 *
 * @param db FMDB的数据库对象
 * @param oldVersion 当期数据库的版本
 * @param lastVersion 要更新的新的数据库的版本
 * @return YES=成功，NO=失败
 */
- (BOOL)onUpgrade:(FMDatabase *)db oldVersion:(int)oldVersion lastVersion:(int)lastVersion {
    return YES;
}
@end

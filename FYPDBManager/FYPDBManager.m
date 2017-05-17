//
//  FYPDBManager.m
//  FYPDBManager
//
//  Created by 凤云鹏 on 2017/5/16.
//  Copyright © 2017年 FYP. All rights reserved.
//

#import "FYPDBManager.h"

@interface FYPDBManager ()


@end

@implementation FYPDBManager
singleton_m(FYPDBManager)



#pragma mark - 业务逻辑

/**
 @brief 插入消息数据
 */
- (void)insertMessage:(NSDictionary *)message{
    [self inTransaction:^BOOL{
        if ([self.db open]) {

            BOOL result = [self.db executeUpdate:@"INSERT INTO t_Users (UserId,LoginId,loginPassword,UserName,Age,Title) VALUES (?,?,?,?,?,?);",message[@"UserId"],message[@"LoginId"],message[@"loginPassword"],message[@"UserName"],message[@"Age"],message[@"Title"]];
            if (result)
            {
                NSLog(@"插入消息成功");
            }
            [self.db close];
            return result;
        }
        return NO;
 
    }];
    
}

/**
 获取所有消息
 *
 *
 */
- (NSArray<NSDictionary *> *)getAllMessage {
    
    __block NSMutableArray *messages = [NSMutableArray arrayWithCapacity:0];
    [self inTransaction:^BOOL{
        if ([self.db open]) {

            FMResultSet *result = [self.db executeQuery:@"select * from t_Users ;"];
            while ([result next]) {
                
                 NSDictionary *user = @{@"UserId":[result stringForColumn:@"UserId"],
                                        @"LoginId":[result stringForColumn:@"LoginId"],
                                        @"loginPassword":[result stringForColumn:@"loginPassword"],
                                        @"UserName":[result stringForColumn:@"UserName"],
                                        @"Age":[result stringForColumn:@"Age"],
                                        @"Title":[result stringForColumn:@"Title"]};
                

                [messages addObject:user];
            }
            [self.db close];
            return YES;
        }
        return NO;
    }];
    return messages;
}


#pragma mark - Custom Property

/**
 * 只读属性，当前项目的数据库版本号，如果下一次数据库表结构或数据要更改，请在原数字上加1.
 *
 * 如：第一次工程创建时dbVersion请设为1；软件迭代升级了几次后要修改数据库表结构或数据要更改，则修改dbVersion=2；每次升级数据库请把版本号累加。
 */
- (int)dbVersion
{
    /*
     备注：
     DB走DB的版本号，App走App的版本号，互不冲突，互不影响，这里备注只是记录而已。
     dbVersion=1，appVersion=1.0：创建第一版数据库。
     dbVersion=2，appVersion=2.3：表t_Users增加了字段MobilePhone。
     dbVersion=3，appVersion=2.4：XXX。
     */
    return DBVERSION;
}

#pragma mark - Override the parent class's methods

/**
 * 第一次创建数据库时的sql。注意不需要写事务，父类已经启动事务
 *
 * @param db FMDB的数据库对象
 */
- (BOOL)onCreate:(FMDatabase *)db
{
    NSLog(@">>> onCreate");
    
    if (!db) {
        NSAssert(0, @"db can't be null");
        return false;
    }
    @try {
        ////////////////////////// 在此处添加第一次创建表和初始化的SQL ///////////////////////////////
        BOOL result = NO;
        
        // 2 执行表创建工作
        // 2.1 用户表
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_Users (UserId TEXT NOT NULL, LoginId TEXT NOT NULL, loginPassword TEXT, UserName TEXT, Age INTEGER, Title TEXT, PRIMARY KEY (UserId));"];
        if (!result) {
            NSLog(@"create table Users Failed");
            return false;
        }
        
        // 2.2 工作日志表
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_Worklog (WorklogId TEXT NOT NULL, Title TEXT NOT NULL, Desc TEXT, Owner TEXT NOT NULL, CreatedTime TEXT NOT NULL, ModifiedTime TEXT NOT NULL, IsDeleted INTEGER, PRIMARY KEY (WorklogId));"];
        if (!result) {
            NSLog(@"create table t_Worklog Failed");
            return false;
        }
        /////////////////////////////////////// END ////////////////////////////////////////////
        
        
        //第一次创建数据库即self.dbVersion=1时，可以不用实现覆盖方法onUpgrade，此处可以直接return true;
        //self.dbVersion>1时,实现覆盖方法onUpgrade并调用它，是为了保证用户从不管从哪个版本新安装，都保证数据库版本更新到最新版。
        //如:用户A数据库版本是v1，用户B是v2，用户C没装过App这次新装；当前数据库版本是v3，安装运行App后，用户A会v1->v2->v3，用户B会v2->v3，用户C会v1->v2->v3依次升级数据库。
        return [self onUpgrade:db oldVersion:1 lastVersion:self.dbVersion];
        
    }
    @catch (NSException *exception) {
        NSAssert1(0, @"Exception: %@", exception.reason);
        return false;
    }
    @finally {
        
    }
    
}

/**
 * 数据库版本增加时的方法，比如数据库表结构发生变化，要从版本v1升级到版本v2
 *
 * @param db FMDB的数据库对象
 * @param oldVersion 当期数据库的版本
 * @param lastVersion 要更新的新的数据库的版本
 */
- (BOOL)onUpgrade:(FMDatabase *)db oldVersion:(int)oldVersion lastVersion:(int)lastVersion
{
    NSLog(@">>> onUpgrade, oldVersion=%d, newVersion=%d", oldVersion, lastVersion);
    
    if (!db) {
        NSAssert(0, @"db can't be null");
        return false;
    }
    
    @try {
        // 升级数据库
        // 使用for实现跨版本升级数据库，代码逻辑始终会保证顺序递增升级。
        BOOL rev = NO;
        for(int ver = oldVersion; ver < lastVersion; ver++) {
            rev = NO;
            switch(ver) {
                case 1: //v1-->v2
                rev = [self upgradeVersion1To2:db];
                break ;
                case 2: //v2-->v3
//                rev = [self upgradeVersion2To3:db];
                break ;
                //有新的版本在此处添加case 3、case 4等等。
                default :
                break ;
            }
            if (!rev) return false;
        }
        
        //
        return true;
    }
    @catch (NSException *exception) {
        NSAssert1(0, @"Exception: %@", exception.reason);
        return false;
    }
    @finally {
        
    }
}

/**
 * 数据库配置检查完成后会调用的方法。可以实现数据库版本升级后的一些后续数据处理。
 * 保留
 * @param db FMDB的数据库对象
 * @param dbCheckIsSuccess 数据库配置检查是否成功了
 */

- (void)didChecked:(FMDatabase *)db dbCheckIsSuccess:(BOOL)dbCheckIsSuccess
{
    if (!dbCheckIsSuccess) return;
    
    //do db something
    //...
    
}

#pragma mark - Custom Method

/**
 * 数据库版本从v1升级到v2。
 *
 * 主要功能有：
 * 给t_Users表增加字段MobilePhone
 */
- (BOOL)upgradeVersion1To2:(FMDatabase *)db
{
    
    //1 判断表是否存在，取出t_Users表创建语句
    FMResultSet *rs = [db executeQuery:@"SELECT sql FROM sqlite_master WHERE type = 'table' AND tbl_name = 't_Users' "];
    NSString *tabCreateSql = nil;
    BOOL tableIsExistus = NO;
    while([rs next]) {
        tableIsExistus = YES;
        tabCreateSql = [rs stringForColumnIndex:0];
        break;
    }
    [rs close];
    if (tableIsExistus && tabCreateSql) {
        //1.2 判断要新增的列MobilePhone是否存，不存在则添加
        NSString *column_FileName = @"MobilePhone";
        NSRange range1 = [tabCreateSql rangeOfString: column_FileName];
        if (range1.length < 1) {
            NSString *sql = [NSString stringWithFormat:@"ALTER TABLE t_Users ADD %@ TEXT NULL; ", column_FileName];
            BOOL rev = [db executeUpdate:sql];
            if (!rev) {
                [db rollback];
                NSLog(@"执行以下sql时失败：\n%@\n失败原因是：%@", sql, [db lastErrorMessage]);
                NSAssert2(0, @"执行以下sql时失败：\n%@\n失败原因是：%@", sql, [db lastErrorMessage]);
                return false;
            }
        }
    }
    return true;
}

@end

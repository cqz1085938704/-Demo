//
//  DatabaseManager.m
//  SQLite缓存
//
//  Created by caiyao's Mac on 2017/6/23.
//  Copyright © 2017年 core's Mac. All rights reserved.
//

#import "DatabaseManager.h"
#import <sqlite3.h>

static sqlite3 *db;
static DatabaseManager *manager = nil;

@interface DatabaseManager ()

@end

@implementation DatabaseManager

+(instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
    });
    return manager;
}

-(void)dealloc
{
    sqlite3_close(db);
}

-(instancetype)init
{
    if (self = [super init])
    {
        [self open];
    }
    return self;
}

-(void)open
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@"my.sqlite"];
    
    int result = sqlite3_open([path UTF8String], &db);
    if (result != SQLITE_OK)
    {
        NSLog(@"数据库打开失败！");
    }
}

-(BOOL)createTableWithSQL:(NSString *)create
{
    BOOL result = YES;
    char *error = nil;
    if (sqlite3_exec(db, [create UTF8String], NULL, NULL, &error) != SQLITE_OK)
    {
        NSLog(@"创建表失败: %s", error);
        result = NO;
    }
    return result;
}

-(BOOL)insert:(NSString *)insert
{
    BOOL result = YES;
    int flag = sqlite3_exec(db, [insert UTF8String], NULL, NULL, NULL);
    if (flag != SQLITE_OK)
    {
        NSLog(@"插入记录失败");
        result = NO;
    }
    return result;
}

-(NSArray *)search:(NSString *)search
{
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(db, [search UTF8String], -1, &stmt, nil) != SQLITE_OK)
    {
        NSLog(@"查询失败！");
        return nil;
    }
    
    NSMutableArray *result = [NSMutableArray array];
    while (sqlite3_step(stmt) == SQLITE_ROW)
    {
        int columnCount = sqlite3_data_count(stmt);
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        for (int i = 0; i < columnCount; i ++)
        {
            NSString *key = [NSString stringWithUTF8String:(char *)sqlite3_column_name(stmt, i)];
            switch (sqlite3_column_type(stmt, i))
            {
                case SQLITE_INTEGER:
                {
                    int intValue = sqlite3_column_int(stmt, i);
                    [dic setObject:[NSNumber numberWithInt:intValue] forKey:key];
                }
                    break;
                case SQLITE_TEXT:
                {
                    NSString * stringValue = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, i)];
                    [dic setObject:stringValue forKey:key];
                }
                    break;
                default:
                    break;
            }
        }
        if (dic)
        {
            [result addObject:dic];
        }
    }
    sqlite3_finalize(stmt);
    return result;
}
@end

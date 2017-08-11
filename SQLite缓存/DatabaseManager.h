//
//  DatabaseManager.h
//  SQLite缓存
//
//  Created by caiyao's Mac on 2017/6/23.
//  Copyright © 2017年 core's Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatabaseManager : NSObject

+(instancetype)sharedInstance;

-(BOOL)createTableWithSQL:(NSString *)create;
-(BOOL)insert:(NSString *)insert;
-(NSArray *)search:(NSString *)search;

@end

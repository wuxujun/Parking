//
//  DBManager.m
//  IWeigh
//
//  Created by xujunwu on 15/5/4.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "DBManager.h"
#import "DBHelper.h"
#import "SearchHisEntity.h"
#import "CollectEntity.h"
#import "PoiInfoEntity.h"

@implementation DBManager

static DBManager *sharedDBManager=nil;
+(DBManager*)getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDBManager=[[DBManager alloc]init];
        
    });
    return sharedDBManager;
}

-(NSArray*)querySearchHistory
{
    return [DBHelper queryAll:[SearchHisEntity class] conditions:@"WHERE 1=1 order by hisId desc" params:@[]];
}

- (BOOL)insertOrUpdateSearchHistory:(NSDictionary *)info
{
    NSInteger count = [self querySearchHisCountWithId:info[@"keyword"]];
    __block BOOL isSuccess;
    if (count == 0) {
        [SearchHisEntity generateInsertSql:info completion:^(NSString *sql, NSArray *arguments) {
            isSuccess = [DBHelper excuteSql:sql withArguments:arguments];
        }];
    }else{
        [SearchHisEntity generateUpdateSql:info completion:^(NSString *sql, NSArray *arguments) {
            isSuccess = [DBHelper excuteSql:sql withArguments:arguments];
        }];
    }
    return isSuccess;
}

- (NSInteger)querySearchHisCountWithId:(NSString *)mId
{
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) from t_search_his WHERE keyword='%@'", mId];
    __block NSInteger count = 0;
    [DBHelper queryCountWithSql:sql params:nil completion:^(NSInteger index) {
        count = index;
    }];
    return count;
}

-(BOOL)deleteSearchHistory
{
    NSString* sql=@"DELETE FROM t_search_his";
    return [DBHelper excuteSql:sql withArguments:@[]];
}


-(NSArray*)queryCollect
{
    return [DBHelper queryAll:[CollectEntity class] conditions:@"WHERE 1=1 order by favId desc" params:@[]];
}

- (BOOL)insertOrUpdateCollect:(NSDictionary *)info
{
    NSInteger count = [self queryCollectCountWithId:info[@"dataId"]];
    __block BOOL isSuccess;
    if (count == 0) {
        [CollectEntity generateInsertSql:info completion:^(NSString *sql, NSArray *arguments) {
            isSuccess = [DBHelper excuteSql:sql withArguments:arguments];
        }];
    }else{
        [CollectEntity generateUpdateSql:info completion:^(NSString *sql, NSArray *arguments) {
            isSuccess = [DBHelper excuteSql:sql withArguments:arguments];
        }];
    }
    return isSuccess;
}

- (NSInteger)queryCollectCountWithId:(NSString *)mId
{
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) from t_my_collect WHERE dataId='%@'", mId];
    __block NSInteger count = 0;
    [DBHelper queryCountWithSql:sql params:nil completion:^(NSInteger index) {
        count = index;
    }];
    return count;
}

-(BOOL)deleteCollect:(NSString*)dataId
{
    NSString* sql=[NSString stringWithFormat:@"DELETE FROM t_my_collect where dataId='%@'",dataId];
    return [DBHelper excuteSql:sql withArguments:@[]];
}

-(BOOL)insertOrUpdatePoiInfo:(NSDictionary *)info
{
    NSInteger count = [self queryPoiInfoCountWithId:info[@"poiId"]];
    __block BOOL isSuccess;
    if (count == 0) {
        [PoiInfoEntity generateInsertSql:info completion:^(NSString *sql, NSArray *arguments) {
            isSuccess = [DBHelper excuteSql:sql withArguments:arguments];
        }];
    }else{
        [PoiInfoEntity generateUpdateSql:info completion:^(NSString *sql, NSArray *arguments) {
            isSuccess = [DBHelper excuteSql:sql withArguments:arguments];
        }];
    }
    return isSuccess;
}

- (NSInteger)queryPoiInfoCountWithId:(NSString *)mId
{
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) from t_poi_info WHERE poiId='%@'", mId];
    __block NSInteger count = 0;
    [DBHelper queryCountWithSql:sql params:nil completion:^(NSInteger index) {
        count = index;
    }];
    return count;
}


-(NSArray*)queryPoiInfo
{
     return [DBHelper queryAll:[PoiInfoEntity class] conditions:@"WHERE 1=1 order by distance" params:@[]];
}

-(NSArray*)queryPoiInfo:(NSString *)charge forType:(NSString *)type
{
    NSString *where=@"WHERE 1=1  order by distance ";
    if ([charge isEqualToString:@"0"]) {
        if (![type isEqualToString:@"0"]) {
            where=[NSString stringWithFormat:@"WHERE typeDes ='%@'  order by distance",type];
        }
    }else{
        if (![type isEqualToString:@"0"]) {
            where=[NSString stringWithFormat:@"WHERE charge='%@' and typeDes='%@' order by distance",charge,type];
        }else{
            where=[NSString stringWithFormat:@"WHERE charge='%@' order by distance",charge];
        }
    }
    return [DBHelper queryAll:[PoiInfoEntity class] conditions:where params:@[]];
}

-(BOOL)deleteAllPoiInfo
{
    NSString* sql=@"DELETE FROM t_poi_info ";
    return [DBHelper excuteSql:sql withArguments:@[]];
}

@end

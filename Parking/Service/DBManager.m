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

-(NSArray*)queryLocalPoiInfo
{
    return [DBHelper queryAll:[PoiInfoEntity class] conditions:@"WHERE sourceType=1 order by distance" params:@[]];
}

-(NSArray*)queryPoiInfo
{
     return [DBHelper queryAll:[PoiInfoEntity class] conditions:@"WHERE 1=1 order by distance" params:@[]];
}

-(NSArray*)queryOtherCity
{
    return [DBHelper queryAll:[PoiInfoEntity class] conditions:@"WHERE sourceType=0 order by distance" params:@[]];
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

-(NSArray*)queryPoiInfo:(NSString *)charge forType:(NSString *)type forStatus:(NSString*)status
{
    NSMutableString * where =[[NSMutableString alloc] init];
    [where appendString:@"WHERE 1=1 "];
    if (![charge isEqualToString:@"0"]) {
        [where appendFormat:@" and charge='%@' ",charge];
    }
    if (![type isEqualToString:@"0"]) {
        [where appendFormat:@" and typeDes ='%@' ",type];
    }
    if (![status isEqualToString:@"0"]) {
        [where appendFormat:@" and freeStatus='%@'",status];
    }
    [where appendString:@" and distance>0 "];
    [where appendString:@" order by distance"];
    
    return [DBHelper queryAll:[PoiInfoEntity class] conditions:where params:@[]];
}

-(NSArray*)queryPoiInfo:(NSString *)charge forType:(NSString *)type forStatus:(NSString*)status forLat:(NSString*)lat forLng:(NSString*)lng
{
    NSMutableString * where =[[NSMutableString alloc] init];
    [where appendString:@"WHERE 1=1 "];
    if (![charge isEqualToString:@"0"]) {
        [where appendFormat:@" and charge='%@' ",charge];
    }
    if (![type isEqualToString:@"0"]) {
        [where appendFormat:@" and typeDes ='%@' ",type];
    }
    if (![status isEqualToString:@"0"]) {
        [where appendFormat:@" and freeStatus='%@'",status];
    }
    [where appendFormat:@" and latitude>%.6f and latitude<%.6f ",([lat floatValue]-0.0045),([lat floatValue]+0.0045)];
    [where appendFormat:@" and longitude>%.6f and longitude<%.6f ",([lng floatValue]-0.0052),([lng floatValue]+0.0052)];
//    [where appendString:@"  limit 0,20 "];
//    [where appendString:@" order by distance"];
    HLog(@"%@",where);
    return [DBHelper queryAll:[PoiInfoEntity class] conditions:where params:@[]];
}

-(BOOL)deletePoiInfo:(NSInteger)sType forDataType:(NSInteger)dType
{
    NSString* sql=[NSString stringWithFormat:@"DELETE FROM t_poi_info where sourceType=%d and dataType=%d ",sType,dType];
//    sql=@"DELETE FROM t_poi_info ";
    return [DBHelper excuteSql:sql withArguments:@[]];
}

-(BOOL)updatePoiInfoDistance
{
    NSString* sql=@"UPDATE t_poi_info SET distance=0  where sourceType=1 ";
    return [DBHelper excuteSql:sql withArguments:@[]];
}

@end

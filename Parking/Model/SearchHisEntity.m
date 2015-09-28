//
//  SearchHisEntity.m
//  Parking
//
//  Created by xujunwu on 15/9/22.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import "SearchHisEntity.h"

@implementation SearchHisEntity

-(void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"hisId"]) {
        self.hisId=[value intValue];
    }else if([key isEqualToString:@"hisType"]){
        self.hisType=[value intValue];
    }else if([key isEqualToString:@"keyword"]){
        self.keyword=value;
    }else if([key isEqualToString:@"cityCode"]){
        self.cityCode=value;
    }else if([key isEqualToString:@"adCode"]){
        self.adCode=value;
    }else if([key isEqualToString:@"latitude"]){
        self.latitude=value;
    }else if([key isEqualToString:@"longitude"]){
        self.longitude=value;
    }else if([key isEqualToString:@"insertTime"]){
        self.insertTime=[value intValue];
    }else if([key isEqualToString:@"dataId"]){
        self.dataId=value;
    }
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

+(NSString*)tableName;
{
    return @"t_search_his";
}

+(NSArray*)fields
{
    return [NSArray arrayWithObjects:@"hisId",@"hisType",@"dataId",@"keyword",@"cityCode",@"adCode",@"latitude",@"longitude",@"insertTime", nil];
}

+ (void)generateInsertSql:(NSDictionary *)aInfo completion:(SqlBlock)completion
{
    NSMutableArray *finalKeys = [NSMutableArray array];
    NSMutableArray *finalValues = [NSMutableArray array];
    NSMutableArray *placeholder = [NSMutableArray array];
    
    NSArray *keys = [aInfo allKeys];
    NSArray *values = [aInfo allValues];
    for (int i=0; i<values.count; i++) {
        NSString *value = values[i];
        NSString *key = keys[i];
        HLog(@"%@:%@",key,value);
        NSArray *integerKeyArray = @[@"hisId", @"hisType", @"insertTime"];
        if ([integerKeyArray containsObject:key]) {
            [finalKeys addObject:key];
            [finalValues addObject:@([value integerValue])];
            [placeholder addObject:@"?"];
        }
        else{
            if (![value isEqual:[NSNull null]] && value.length > 0){
                [finalValues addObject:value];
            }else{
                [finalValues addObject:@""];
            }
            [finalKeys addObject:key];
            [placeholder addObject:@"?"];
        }
    }
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO t_search_his (%@) values (%@)", [finalKeys componentsJoinedByString:@", "], [placeholder componentsJoinedByString:@", "]];
    HLog(@"%@",sql);
    if (completion) {
        completion(sql, finalValues);
    }
}

+ (void)generateUpdateSql:(NSDictionary *)aInfo completion:(SqlBlock)completion
{
    NSArray *keys = [aInfo allKeys];
    NSArray *values = [aInfo allValues];
    
    NSMutableArray *kvPairs = [NSMutableArray array];
    NSMutableArray *finalValues = [NSMutableArray array];
    
    NSNumber *mID = nil;
    for (int i=0; i<values.count; i++) {
        NSString *value = values[i];
        NSString *key = keys[i];
        
        NSArray *integerKeyArray = @[@"hisId", @"hisType", @"insertTime"];
        if ([integerKeyArray containsObject:key]) {
            if ([key isEqualToString:@"hisId"]) {
                mID = @([value integerValue]);
            }else{
                [finalValues addObject:@([value integerValue])];
                [kvPairs addObject:[NSString stringWithFormat:@"%@=?", keys[i]]];
            }
        }
        else{
            if (![value isEqual:[NSNull null]] && value.length > 0) {
                [finalValues addObject:value];
            }else{
                [finalValues addObject:@""];
            }
            [kvPairs addObject:[NSString stringWithFormat:@"%@=?", keys[i]]];
        }
    }
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE t_search_his set %@ WHERE hisId=%@", [kvPairs componentsJoinedByString:@", " ], mID];
    HLog(@"%@",sql);
    if (completion) {
        completion(sql, finalValues);
    }
}


    

@end

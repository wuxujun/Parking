//
//  CollectEntity.m
//  Parking
//
//  Created by xujunwu on 15/9/22.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import "CollectEntity.h"

@implementation CollectEntity
-(void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"favId"]) {
        self.favId=[value intValue];
    }else if([key isEqualToString:@"favType"]){
        self.favType=[value intValue];
    }else if([key isEqualToString:@"title"]){
        self.title=value;
    }else if([key isEqualToString:@"dataId"]){
        self.dataId=value;
    }else if([key isEqualToString:@"favTime"]){
        self.favTime=[value intValue];
    }else if([key isEqualToString:@"latitude"]){
        self.latitude=value;
    }else if([key isEqualToString:@"longitude"]){
        self.longitude=value;
    }else if([key isEqualToString:@"address"]){
        self.address=value;
    }else if([key isEqualToString:@"sourceType"]){
        self.sourceType=[value intValue];
    }else if([key isEqualToString:@"dataType"]){
        self.dataType=[value intValue];
    }
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

+(NSString*)tableName;
{
    return @"t_my_collect";
}

+(NSArray*)fields
{
    return [NSArray arrayWithObjects:@"favId",@"favType",@"dataId",@"title",@"favTime",@"latitude",@"longitude",@"address",@"sourceType",@"dataType", nil];
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
        NSArray *integerKeyArray = @[@"favId", @"favType",@"favTime",@"sourceType",@"dataType"];
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
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO t_my_collect (%@) values (%@)", [finalKeys componentsJoinedByString:@", "], [placeholder componentsJoinedByString:@", "]];
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
        
        NSArray *integerKeyArray = @[@"favId", @"favType",@"favTime",@"sourceType",@"dataType"];
        if ([integerKeyArray containsObject:key]) {
            if ([key isEqualToString:@"favId"]) {
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
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE t_my_collect set %@ WHERE favId=%@", [kvPairs componentsJoinedByString:@", " ], mID];
    HLog(@"%@",sql);
    if (completion) {
        completion(sql, finalValues);
    }
}

@end

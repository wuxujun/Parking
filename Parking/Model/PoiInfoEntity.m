//
//  PoiInfoEntity.m
//  Parking
//
//  Created by xujunwu on 15/9/23.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import "PoiInfoEntity.h"

@implementation PoiInfoEntity

-(void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"pid"]) {
        self.pid=[value intValue];
    }else if([key isEqualToString:@"poiId"]){
        self.poiId=value;
    }else if([key isEqualToString:@"typeDes"]){
        self.typeDes=value;
    }else if([key isEqualToString:@"title"]){
        self.title=value;
    }else if([key isEqualToString:@"address"]){
        self.address=value;
    }else if([key isEqualToString:@"distance"]){
        self.distance=[value intValue];
    }else if([key isEqualToString:@"totalCount"]){
        self.totalCount=[value intValue];
    }else if([key isEqualToString:@"freeCount"]){
        self.freeCount=[value intValue];
    }else if([key isEqualToString:@"freeStatus"]){
        self.freeStatus=value;
    }else if([key isEqualToString:@"parkRiveType"]){
        self.parkRiveType=value;
    }else if([key isEqualToString:@"charge"]){
        self.charge=value;
    }else if([key isEqualToString:@"chargeDetail"]){
        self.chargeDetail=value;
    }else if([key isEqualToString:@"price"]){
        self.price=[value intValue];
    }else if([key isEqualToString:@"latitude"]){
        self.latitude=value;
    }else if([key isEqualToString:@"longitude"]){
        self.longitude=value;
    }else if([key isEqualToString:@"sourceType"]){
        self.sourceType=[value intValue];
    }else if([key isEqualToString:@"dataType"]){
        self.dataType=[value intValue];
    }else if([key isEqualToString:@"cityCode"]){
        self.cityCode=value;
    }else if([key isEqualToString:@"adCode"]){
        self.adCode=value;
    }else if([key isEqualToString:@"idx"]){
        self.idx=[value intValue];
    }
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

+(NSString*)tableName;
{
    return @"t_poi_info";
}

+(NSArray*)fields
{
    return [NSArray arrayWithObjects:@"pid",@"poiId",@"typeDes",@"idx",@"title",@"address",@"distance",@"totalCount",@"freeCount",@"charge",@"chargeDetail",@"price",@"latitude",@"longitude",@"sourceType",@"dataType",@"cityCode",@"adCode",@"freeStatus",@"parkRiveType", nil];
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
        NSArray *integerKeyArray = @[@"pid",@"idx", @"distance",@"totalCount",@"freeCount",@"price",@"sourceType",@"dataType"];
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
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO t_poi_info (%@) values (%@)", [finalKeys componentsJoinedByString:@", "], [placeholder componentsJoinedByString:@", "]];
//    HLog(@"%@",sql);
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
        
        NSArray *integerKeyArray = @[@"pid", @"idx",@"distance",@"totalCount",@"freeCount",@"price",@"sourceType",@"dataType"];
        if ([integerKeyArray containsObject:key]) {
            if ([key isEqualToString:@"pid"]) {
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
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE t_poi_info set %@ WHERE pid=%@", [kvPairs componentsJoinedByString:@", " ], mID];
    HLog(@"%@",sql);
    if (completion) {
        completion(sql, finalValues);
    }
}

@end

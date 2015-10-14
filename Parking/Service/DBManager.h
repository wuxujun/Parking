//
//  DBManager.h
//  IWeigh
//
//  Created by xujunwu on 15/5/4.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBManager : NSObject

+(DBManager*)getInstance;

-(BOOL)insertOrUpdateSearchHistory:(NSDictionary*)info;
-(NSArray*)querySearchHistory;
-(BOOL)deleteSearchHistory;

-(NSInteger)queryCollectCountWithId:(NSString *)mId;
-(BOOL)insertOrUpdateCollect:(NSDictionary*)info;
-(NSArray*)queryCollect;
-(BOOL)deleteCollect:(NSString*)dataId;


-(BOOL)insertOrUpdatePoiInfo:(NSDictionary *)info;
-(NSArray*)queryPoiInfo;
-(NSArray*)queryPoiInfo:(NSString*)charge forType:(NSString*)type;
-(NSArray*)queryPoiInfo:(NSString*)charge forType:(NSString*)type forStatus:(NSString*)status;
-(BOOL)deleteAllPoiInfo;

@end

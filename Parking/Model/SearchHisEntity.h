//
//  SearchHisEntity.h
//  Parking
//
//  Created by xujunwu on 15/9/22.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SqlBlock)(NSString* sql,NSArray *arguments);

@interface SearchHisEntity : NSObject
@property(nonatomic,assign) NSInteger   hisId;
@property(nonatomic,assign) NSInteger   hisType;
@property(nonatomic,strong) NSString*   dataId;
@property(nonatomic,strong) NSString*   keyword;
@property(nonatomic,strong) NSString*   cityCode;
@property(nonatomic,strong) NSString*   adCode;
@property(nonatomic,strong) NSString*   latitude;
@property(nonatomic,strong) NSString*   longitude;
@property(nonatomic,assign) NSInteger   insertTime;

+(void)generateInsertSql:(NSDictionary*)aInfo completion:(SqlBlock)completion;
+(void)generateUpdateSql:(NSDictionary*)aInfo completion:(SqlBlock)completion;


@end

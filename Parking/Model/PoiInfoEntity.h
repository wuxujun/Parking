//
//  PoiInfoEntity.h
//  Parking
//
//  Created by xujunwu on 15/9/23.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^SqlBlock)(NSString* sql,NSArray *arguments);

@interface PoiInfoEntity : NSObject

@property(nonatomic,assign) NSInteger   pid;
@property(nonatomic,strong) NSString*   poiId;
@property(nonatomic,strong) NSString*   typeDes;
@property(nonatomic,strong) NSString*   title;
@property(nonatomic,strong) NSString*   address;
@property(nonatomic,assign) NSInteger   distance;
@property(nonatomic,assign) NSInteger   totalCount;
@property(nonatomic,assign) NSInteger   freeCount;
@property(nonatomic,strong) NSString*   charge;
@property(nonatomic,strong) NSString*   chargeDetail;
@property(nonatomic,assign) NSInteger   price;
@property(nonatomic,strong) NSString*   latitude;
@property(nonatomic,strong) NSString*   longitude;
@property(nonatomic,assign) NSInteger   sourceType;
@property(nonatomic,assign) NSInteger   dataType;
@property(nonatomic,strong) NSString*   cityCode;
@property(nonatomic,strong) NSString*   adCode;
@property(nonatomic,assign) NSInteger    idx;

+(void)generateInsertSql:(NSDictionary*)aInfo completion:(SqlBlock)completion;
+(void)generateUpdateSql:(NSDictionary*)aInfo completion:(SqlBlock)completion;

@end

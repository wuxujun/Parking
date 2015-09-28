//
//  CollectEntity.h
//  Parking
//
//  Created by xujunwu on 15/9/22.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^SqlBlock)(NSString* sql,NSArray *arguments);


@interface CollectEntity : NSObject

@property(nonatomic,assign) NSInteger   favId;
@property(nonatomic,assign) NSInteger   favType;
@property(nonatomic,strong) NSString*   dataId;
@property(nonatomic,strong) NSString*   title;
@property(nonatomic,strong) NSString*   address;
@property(nonatomic,strong) NSString*   latitude;
@property(nonatomic,strong) NSString*   longitude;
@property(nonatomic,assign) NSInteger   sourceType;
@property(nonatomic,assign) NSInteger   dataType;
@property(nonatomic,assign) NSInteger   favTime;

+(void)generateInsertSql:(NSDictionary*)aInfo completion:(SqlBlock)completion;
+(void)generateUpdateSql:(NSDictionary*)aInfo completion:(SqlBlock)completion;


@end

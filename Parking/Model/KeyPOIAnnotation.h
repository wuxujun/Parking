//
//  KeyPOIAnnotation.h
//  Parking
//
//  Created by xujunwu on 15/9/1.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AMapNaviKit/MAMapKit.h>
#import <AMapSearchKit/AMapCommonObj.h>
#import "SearchHisEntity.h"

@interface KeyPOIAnnotation : NSObject<MAAnnotation>

-(id)initWithPOI:(AMapPOI*)poi;
-(id)initWithSearchHisEntity:(SearchHisEntity *)entity;

@property(nonatomic,readonly,strong) SearchHisEntity*   entity;
@property(nonatomic,readonly,strong) AMapPOI *poi;
@property(nonatomic,readonly)CLLocationCoordinate2D     coordinate;

-(NSString*)title;
-(NSString*)subtitle;

@end

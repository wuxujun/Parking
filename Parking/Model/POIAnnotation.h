//
//  POIAnnotation.h
//  Parking
//
//  Created by xujunwu on 15/9/1.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapNaviKit/MAMapKit.h>
#import <AMapSearchKit/AMapCommonObj.h>
#import "PoiInfoEntity.h"

@interface POIAnnotation : NSObject<MAAnnotation>

-(id)initWithPOI:(AMapPOI*)poi index:(NSInteger)idx  isSelected:(BOOL)sel;
-(id)initWithPoiInfoEntity:(PoiInfoEntity*)entity index:(NSInteger)idx  isSelected:(BOOL)sel;

@property(nonatomic,readonly,strong) PoiInfoEntity*  entity;
@property(nonatomic,readonly,strong) AMapPOI *poi;
@property(nonatomic,readonly,assign)NSInteger   index;
@property(nonatomic,readonly,assign)BOOL        isSelected;
@property(nonatomic,readonly)CLLocationCoordinate2D     coordinate;

-(NSString*)title;
-(NSString*)subtitle;

@end

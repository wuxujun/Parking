//
//  POIAnnotation.m
//  Parking
//
//  Created by xujunwu on 15/9/1.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "POIAnnotation.h"

@interface POIAnnotation()
@property(nonatomic,readwrite,strong)PoiInfoEntity  *entity;
@property (nonatomic,readwrite,strong)AMapPOI *poi;
@property (nonatomic,readwrite,assign)NSInteger index;
@property (nonatomic,readwrite,assign)NSInteger dataType;
@property (nonatomic,readwrite,assign)BOOL      isSelected;
@end
@implementation POIAnnotation
@synthesize poi=_poi;
@synthesize dataType=_dataType;
@synthesize index=_index;
@synthesize isSelected=_isSelected;
@synthesize entity=_entity;

-(NSString*)title
{
    if (self.entity) {
        return self.entity.title;
    }
    return self.poi.name;
}

-(NSString*)subtitle
{
    if (self.entity) {
        return self.entity.typeDes;
    }
    return self.poi.address;
}

-(CLLocationCoordinate2D)coordinate
{
    if (self.entity) {
        return CLLocationCoordinate2DMake([self.entity.latitude floatValue], [self.entity.longitude floatValue]);
    }
    return CLLocationCoordinate2DMake(self.poi.location.latitude, self.poi.location.longitude);
}

-(id)initWithPOI:(AMapPOI *)poi forType:(NSInteger)dType index:(NSInteger)idx isSelected:(BOOL)sel
{
    if (self==[super init]) {
        self.poi=poi;
        self.dataType=dType;
        self.index=idx;
        self.isSelected=sel;
    }
    return self;
}

-(id)initWithPoiInfoEntity:(PoiInfoEntity *)entity forType:(NSInteger)dType index:(NSInteger)idx isSelected:(BOOL)sel
{
    if (self==[super init]) {
        self.entity=entity;
        self.dataType=dType;
        self.index=idx;
        self.isSelected=sel;
    }
    return self;
}

@end

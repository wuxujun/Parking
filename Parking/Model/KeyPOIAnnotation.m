//
//  KeyPOIAnnotation.m
//  Parking
//
//  Created by xujunwu on 15/9/1.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "KeyPOIAnnotation.h"

@interface KeyPOIAnnotation()
@property (nonatomic,readwrite,strong)AMapPOI *poi;
@property(nonatomic,readwrite,strong)SearchHisEntity*   entity;
@end

@implementation KeyPOIAnnotation
@synthesize poi=_poi;
@synthesize entity=_entity;

-(NSString*)title
{
    if (self.poi) {
        return self.poi.name;
    }
    return self.entity.keyword;
}

-(NSString*)subtitle
{
    if (self.poi) {
        return self.poi.address;
    }
    return self.entity.keyword;
}

-(CLLocationCoordinate2D)coordinate
{
    if (self.poi) {
        return CLLocationCoordinate2DMake(self.poi.location.latitude, self.poi.location.longitude);
    }
    return CLLocationCoordinate2DMake([self.entity.latitude doubleValue],[self.entity.longitude doubleValue]);
}

-(id)initWithPOI:(AMapPOI *)poi
{
    if (self==[super init]) {
        self.poi=poi;
    }
    return self;
}

-(id)initWithSearchHisEntity:(SearchHisEntity *)entity
{
    if (self==[super init]) {
        self.entity=entity;
    }
    return self;
}

@end
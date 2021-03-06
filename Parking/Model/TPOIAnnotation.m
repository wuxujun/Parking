//
//  TPOIAnnotation.m
//  Parking
//
//  Created by xujunwu on 15/10/2.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import "TPOIAnnotation.h"
@interface TPOIAnnotation()
@property(nonatomic,readwrite,strong)PoiInfoEntity  *entity;
@property (nonatomic,readwrite,strong)AMapPOI *poi;
@property (nonatomic,readwrite,assign)NSInteger index;
@property (nonatomic,readwrite,assign)BOOL      isSelected;
@end
@implementation TPOIAnnotation
@synthesize poi=_poi;
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

-(id)initWithPOI:(AMapPOI *)poi index:(NSInteger)idx isSelected:(BOOL)sel
{
    if (self==[super init]) {
        self.poi=poi;
        self.index=idx;
        self.isSelected=sel;
    }
    return self;
}

-(id)initWithPoiInfoEntity:(PoiInfoEntity *)entity index:(NSInteger)idx isSelected:(BOOL)sel
{
    if (self==[super init]) {
        self.entity=entity;
        self.index=idx;
        self.isSelected=sel;
    }
    return self;
}
@end

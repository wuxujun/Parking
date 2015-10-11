//
//  SPOIAnnotation.m
//  Parking
//
//  Created by xujunwu on 15/10/11.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import "SPOIAnnotation.h"

@interface SPOIAnnotation()

@property(nonatomic,readwrite,assign)float  latitude;
@property(nonatomic,readwrite,assign)float  longitude;

@end

@implementation SPOIAnnotation
@synthesize latitude=_latitude;
@synthesize longitude=_longitude;

-(NSString*)title
{
    return @"地图选点";
}

-(NSString*)subtitle
{
    return @"1";
}

-(CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

-(id)initWithPOI:(float)latitude lng:(float)longitude
{
    if (self==[super init]) {
        self.latitude=latitude;
        self.longitude=longitude;
    }
    return self;
}

@end

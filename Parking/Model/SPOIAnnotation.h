//
//  SPOIAnnotation.h
//  Parking
//
//  Created by xujunwu on 15/10/11.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapNaviKit/MAMapKit.h>
#import <AMapSearchKit/AMapCommonObj.h>

@interface SPOIAnnotation : NSObject<MAAnnotation>

-(id)initWithPOI:(float)latitude lng:(float)longitude;
@property(nonatomic,readonly,assign) float   latitude;
@property(nonatomic,readonly,assign) float   longitude;
@property(nonatomic,readonly)CLLocationCoordinate2D     coordinate;

-(NSString*)title;
-(NSString*)subtitle;
@end

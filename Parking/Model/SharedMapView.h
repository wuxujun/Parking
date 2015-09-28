//
//  SharedMapView.h
//  Parking
//
//  Created by xujunwu on 15/8/19.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapNaviKit/MAMapKit.h>

@interface SharedMapView : NSObject

@property (nonatomic, readonly) MAMapView *mapView;

+ (instancetype)sharedInstance;

- (void)stashMapViewStatus;
- (void)popMapViewStatus;

@end

//
//  HomeViewController.h
//  Parking
//
//  Created by xujunwu on 14-7-11.
//  Copyright (c) 2014年 ___Hongkui___. All rights reserved.
//

#import "BMapViewController.h"
#import <AMapNaviKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import <UMSocial.h>
#import "SearchHisEntity.h"

@interface HomeViewController : BMapViewController<AMapSearchDelegate,UMSocialUIDelegate>

-(void)selectPOIAnnotationForIndex:(NSInteger)idx;
-(void)clearAllAnnotationPOI;
-(void)clearAnnotationPOI:(NSInteger)type;

-(void)openViewController:(int)type;
-(void)searchForKeyword:(NSDictionary*)dict;
-(void)searchHisForKeyword:(SearchHisEntity*)entity;
-(void)searchForAMapPOI:(AMapPOI*)poi;
-(void)searchForAMapTip:(AMapTip* )tip;

@end

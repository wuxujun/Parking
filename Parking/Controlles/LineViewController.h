//
//  LineViewController.h
//  Parking
//
//  Created by xujunwu on 15/9/1.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "BViewController.h"
#import <AMapNaviKit/MAMapKit.h>
#import <AMapNaviKit/AMapNaviKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>

@interface LineViewController : BViewController<AMapSearchDelegate>

@property(nonatomic,assign)NSInteger     lineType;
@property(nonatomic,strong)NSDictionary* startPoint;
@property(nonatomic,strong)NSDictionary* endPoint;
@end

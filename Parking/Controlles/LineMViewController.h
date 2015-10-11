//
//  LineMViewController.h
//  Parking
//
//  Created by xujunwu on 15/10/9.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import "NMapViewController.h"
#import <AMapNaviKit/MAMapKit.h>
#import <AMapNaviKit/AMapNaviKit.h>

@interface LineMViewController : NMapViewController

@property(nonatomic,assign)NSInteger     lineType;
@property(nonatomic,strong)NSDictionary* startPoint;
@property(nonatomic,strong)NSDictionary* endPoint;

@end

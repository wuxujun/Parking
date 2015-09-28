//
//  NaviViewController.h
//  Parking
//
//  Created by xujunwu on 15/9/1.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "NMapViewController.h"

@interface NaviViewController : NMapViewController

@property(nonatomic,assign)NSInteger     naviType;
@property(nonatomic,strong)NSDictionary* startPoint;
@property(nonatomic,strong)NSDictionary* endPoint;


@end

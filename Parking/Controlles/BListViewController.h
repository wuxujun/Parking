//
//  BListViewController.h
//  Parking
//  公交线路list
//  Created by xujunwu on 15/9/16.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "BViewController.h"
#import <AMapSearchKit/AMapSearchAPI.h>

@interface BListViewController : BViewController<AMapSearchDelegate>
@property(nonatomic,strong)NSDictionary*    startPoint;

@end

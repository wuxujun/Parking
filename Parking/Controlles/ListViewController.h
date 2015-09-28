//
//  ListViewController.h
//  Parking
//
//  Created by xujunwu on 15/8/31.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "BViewController.h"

@interface ListViewController : BViewController

@property(nonatomic,assign)NSInteger        sourceType;
@property(nonatomic,assign)NSInteger              dataType;
@property(nonatomic,strong)NSDictionary*    startPoint;

@end

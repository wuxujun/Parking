//
//  SearchViewController.h
//  Parking
//
//  Created by xujunwu on 15/8/31.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "BViewController.h"
#import <AMapSearchKit/AMapSearchAPI.h>
#import "iflyMSC/IFlyRecognizerView.h"
#import "iflyMSC/IFlyRecognizerViewDelegate.h"

@interface SearchViewController : BViewController<AMapSearchDelegate,IFlyRecognizerViewDelegate>

@property(nonatomic,strong)AMapSearchAPI *searchAPI;

@property(nonatomic,assign)NSInteger    searchType;
@property(nonatomic,strong)NSString*    searchKeyword;

@property(nonatomic,strong)NSDictionary* startPoint;

@end

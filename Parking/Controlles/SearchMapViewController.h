//
//  SearchMapViewController.h
//  Parking
//
//  Created by xujunwu on 15/9/21.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import "BMapViewController.h"
#import <AMapSearchKit/AMapSearchAPI.h>
#import "iflyMSC/IFlyRecognizerView.h"
#import "iflyMSC/IFlyRecognizerViewDelegate.h"

@interface SearchMapViewController : BMapViewController<AMapSearchDelegate,IFlyRecognizerViewDelegate>

@property(nonatomic,strong)AMapSearchAPI *searchAPI;

@property(nonatomic,assign)NSInteger    searchType;
@property(nonatomic,strong)NSString*    searchKeyword;

@property(nonatomic,strong)NSDictionary* startPoint;

@end

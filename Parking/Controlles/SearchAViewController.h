//
//  SearchAViewController.h
//  Parking
//
//  Created by xujunwu on 15/10/9.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import "BViewController.h"
#import <AMapSearchKit/AMapSearchAPI.h>
#import "iflyMSC/IFlyRecognizerView.h"
#import "iflyMSC/IFlyRecognizerViewDelegate.h"

@interface SearchAViewController : BViewController<IFlyRecognizerViewDelegate>

@property(nonatomic,assign)NSInteger    searchType;  //1 关键字  2 附近
@property(nonatomic,strong)NSString*    searchKeyword;

@property(nonatomic,strong)NSDictionary* startPoint;

@end

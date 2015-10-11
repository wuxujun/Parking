//
//  HomeInfoViewController.h
//  Parking
//
//  Created by xujunwu on 15/9/28.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeInfoView.h"

@protocol HomeInfoViewControllerDelegate;

@interface HomeInfoViewController : UIViewController

@property(nonatomic,strong)NSDictionary*    infoDict;
@property(nonatomic,assign)id<HomeInfoViewControllerDelegate> delegate;

-(void)refresh;
@end


@protocol HomeInfoViewControllerDelegate <NSObject>

-(void)onHomeInfoViewClicked:(NSDictionary*)infoDict type:(int)aType;

@end
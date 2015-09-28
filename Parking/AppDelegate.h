//
//  AppDelegate.h
//  Parking
//
//  Created by xujunwu on 14-7-11.
//  Copyright (c) 2014年 ___Hongkui___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"
#import "REFrostedViewController.h"
#import "HomeViewController.h"
#import "iflyMSC/IFlyDataUploader.h"
#import "HNetworkEngine.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,REFrostedViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController*     rootViewController;
@property (strong, nonatomic) HomeViewController*   homeViewController;

@property(nonatomic,strong)IFlyDataUploader         *iflyDataUploader;
@property(nonatomic,strong)HNetworkEngine           *networkEngine;

@property (nonatomic,strong)id<GAITracker>    tracker;

@end

//
//  NMapViewController.h
//  Parking
//
//  Created by xujunwu on 15/9/2.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapNaviKit/MAMapKit.h>
#import <AMapNaviKit/AMapNaviKit.h>
#import "iflyMSC/IFlySpeechSynthesizer.h"
#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"

@interface NMapViewController : UIViewController<MAMapViewDelegate,AMapNaviManagerDelegate,IFlySpeechSynthesizerDelegate>


@property (nonatomic,strong)MAMapView      *mapView;
@property(nonatomic,strong) AMapNaviManager         *naviManager;
@property(nonatomic,strong) IFlySpeechSynthesizer   *iFlySpeechSynthesizer;
@property(nonatomic,assign)BOOL             isStop;

@end

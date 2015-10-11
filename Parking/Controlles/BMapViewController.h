//
//  BMapViewController.h
//  Parking
//
//  Created by xujunwu on 14-7-12.
//  Copyright (c) 2014年 ___Hongkui___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HNetworkEngine.h"
#import <AMapNaviKit/MAMapKit.h>
#import <AMapNaviKit/AMapNaviKit.h>
#import "iflyMSC/IFlySpeechSynthesizer.h"
#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"
#import "iflyMSC/IFlyRecognizerView.h"
#import "iflyMSC/IFlyRecognizerViewDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>

@interface BMapViewController : UIViewController<MAMapViewDelegate,IFlySpeechSynthesizerDelegate,IFlyRecognizerViewDelegate>

@property (nonatomic,strong)MAMapView      *mapView;
@property(nonatomic,strong) IFlySpeechSynthesizer   *iFlySpeechSynthesizer;
@property(nonatomic,strong)NSString*                cityCode;
@property(nonatomic,strong)HNetworkEngine           *networkEngine;
@property(nonatomic,strong)MAUserLocation    *userLocationAnnotation;

-(void)startIFlyRecognizer;
-(void)searchForVoiceKeyword:(NSString*)keyword;

-(void)alertRequestResult:(NSString*)message;


@end

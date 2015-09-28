//
//  NaviViewController.m
//  Parking
//
//  Created by xujunwu on 15/9/1.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "NaviViewController.h"

@interface NaviViewController()<AMapNaviViewControllerDelegate>

@property(nonatomic,strong)AMapNaviViewController   *naviViewcontroller;

@end

@implementation NaviViewController
@synthesize naviType=_naviType;
@synthesize startPoint=_startPoint;
@synthesize endPoint=_endPoint;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    
    [self initNaviViewController];
    
    [self startNavi];
}


-(void)initNaviViewController
{
    if (_naviViewcontroller==nil) {
        _naviViewcontroller=[[AMapNaviViewController alloc]initWithMapView:self.mapView delegate:self];
    }
}

-(void)startNavi
{
    AMapNaviPoint* startP=[AMapNaviPoint locationWithLatitude:[[self.startPoint objectForKey:@"latitude"] floatValue] longitude:[[self.startPoint objectForKey:@"longitude"] floatValue]];
    
    AMapNaviPoint *endP=[AMapNaviPoint locationWithLatitude:[[self.endPoint objectForKey:@"latitude"] floatValue] longitude:[[self.endPoint objectForKey:@"longitude"] floatValue]];
    NSArray* startPoints=@[startP];
    NSArray* endPoints=@[endP];
    
    if (self.naviType==1) {
        [self.naviManager calculateDriveRouteWithStartPoints:startPoints endPoints:endPoints wayPoints:nil drivingStrategy:AMapNaviDrivingStrategyDefault];
    }else{
        [self.naviManager calculateWalkRouteWithStartPoints:startPoints endPoints:endPoints];
    }
    
}

#pragma mark - AMapNaviManager Delegate
-(void)naviManager:(AMapNaviManager *)naviManager didPresentNaviViewController:(UIViewController *)naviViewController{
    [super naviManager:naviManager didPresentNaviViewController:naviViewController];
    [self.naviManager startGPSNavi];
//    [self.naviManager startEmulatorNavi];
}

-(void)naviManagerOnCalculateRouteSuccess:(AMapNaviManager *)naviManager
{
    [super naviManagerOnCalculateRouteSuccess:naviManager];
    [self.naviManager presentNaviViewController:self.naviViewcontroller animated:YES];
}

#pragma mark - AMapNaviViewController Delegate
-(void)naviViewControllerCloseButtonClicked:(AMapNaviViewController *)naviViewController
{
    self.isStop=YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.iFlySpeechSynthesizer stopSpeaking];
    });
    [self.naviManager stopNavi];
    [self.naviManager dismissNaviViewControllerAnimated:YES];
}

-(void)naviViewControllerMoreButtonClicked:(AMapNaviViewController *)naviViewController
{
    if (self.naviViewcontroller.viewShowMode==AMapNaviViewShowModeCarNorthDirection) {
        self.naviViewcontroller.viewShowMode=AMapNaviViewShowModeMapNorthDirection;
    }else{
        self.naviViewcontroller.viewShowMode=AMapNaviViewShowModeCarNorthDirection;
    }
}

-(void)naviViewControllerTurnIndicatorViewTapped:(AMapNaviViewController *)naviViewController
{
    [self.naviManager readNaviInfoManual];
}

@end

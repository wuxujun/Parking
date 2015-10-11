//
//  NMapViewController.m
//  Parking
//
//  Created by xujunwu on 15/9/2.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "NMapViewController.h"
#import "SharedMapView.h"
#import <AudioToolbox/AudioToolbox.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import "POIAnnotation.h"
#import "CustPOIAnnotation.h"
#import "KeyPOIAnnotation.h"
#import "UIImage+TextMask.h"

@interface NMapViewController ()<CLLocationManagerDelegate>
{
    CLLocationManager       *locManager;
    
}

@property (nonatomic,strong)MAAnnotationView *userLocationAnnotationView;

@end

@implementation NMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (IOS_VERSION_7_OR_ABOVE) {
        self.navigationController.navigationBar.barTintColor=DEFAULT_NAVIGATION_BACKGROUND_COLOR;
    }
    
    if ([CLLocationManager locationServicesEnabled]) {
        locManager=[[CLLocationManager alloc] init];
        locManager.delegate=self;
        locManager.desiredAccuracy=kCLLocationAccuracyBest;
        locManager.distanceFilter=1000;
        if (IOS_VERSION_8_OR_ABOVE) {
            [locManager requestAlwaysAuthorization];
        }
    }
    self.isStop=NO;
    
    [self initMapView];
    [self initNaviManager];
    [self initIFlySpeech];
}

- (void)initMapView
{
    if (self.mapView == nil)
    {
        self.mapView = [[SharedMapView sharedInstance] mapView];
    }
    
    [[SharedMapView sharedInstance] stashMapViewStatus];
    
    
    self.mapView.frame = self.view.bounds;
    
    self.mapView.delegate = self;
}


-(void)initNaviManager
{
    if (self.naviManager==nil) {
        _naviManager=[[AMapNaviManager alloc]init];
    }
    self.naviManager.delegate=self;
}

-(void)initIFlySpeech
{
    if (self.iFlySpeechSynthesizer==nil) {
        _iFlySpeechSynthesizer=[IFlySpeechSynthesizer sharedInstance];
        
    }
    _iFlySpeechSynthesizer.delegate=self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _mapView.delegate=self;
    _mapView.showsUserLocation=NO;
    _mapView.userTrackingMode=MAUserTrackingModeFollow;
    _mapView.showsUserLocation=YES;
    
    _mapView.showsCompass=YES;
    _mapView.compassOrigin=CGPointMake(5, 66);
    _mapView.showsScale=YES;
    _mapView.scaleOrigin=CGPointMake(40,66);
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _mapView.delegate=nil;
    _mapView.showsUserLocation=NO;
    if (locManager) {
        [locManager stopUpdatingLocation];
    }
}

-(MAOverlayView*)mapView:(MAMapView *)mapView viewForOverlay:(id<MAOverlay>)overlay
{
    //    if (overlay==mapView.userLocationAccuracyCircle) {
    //        MACircleView *aview=[[MACircleView alloc]initWithCircle:overlay];
    //        aview.lineWidth=2.0;
    //        aview.strokeColor=[UIColor lightGrayColor];
    //        aview.fillColor=[UIColor colorWithRed:1 green:0 blue:0 alpha:3];
    //        return aview;
    //    }
    return nil;
}

-(MAAnnotationView*)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation{
    if ([annotation isKindOfClass:[MAUserLocation class]]) {
        static NSString* uLocation=@"uLocation";
        MAAnnotationView *anView=[mapView dequeueReusableAnnotationViewWithIdentifier:uLocation];
        if (anView==nil) {
            anView=[[MAPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:uLocation];
        }
        anView.image=[UIImage imageNamed:@"userPosition"];
        self.userLocationAnnotationView=anView;
        return anView;
    }
    if ([annotation isKindOfClass:[POIAnnotation class]]) {
        POIAnnotation* poi=(POIAnnotation*)annotation;
        static NSString* uLocation=@"custPoi";
        MAAnnotationView *anView=[mapView dequeueReusableAnnotationViewWithIdentifier:uLocation];
        if (anView==nil) {
            anView=[[MAPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:uLocation];
        }
        NSString *img=@"icon_blue_bg";
        UIColor *txtColor=[UIColor blueColor];
        if (poi.isSelected) {
            img=@"icon_red_bg";
            txtColor=[UIColor redColor];
        }
        if ((poi.index+1)==10) {
            anView.image=[[UIImage imageNamed:img] imageTextMaskWithString:[NSString stringWithFormat:@"%d",(poi.index+1)] rect:CGRectMake(9, 5, 20, 20) attribute:@{NSForegroundColorAttributeName:txtColor}];
        }else{
            anView.image=[[UIImage imageNamed:img] imageTextMaskWithString:[NSString stringWithFormat:@"%d",(poi.index+1)] rect:CGRectMake(13, 5, 10, 20) attribute:@{NSForegroundColorAttributeName:txtColor}];
        }
        anView.centerOffset=CGPointMake(0, -18);
        return anView;
    }
    if ([annotation isKindOfClass:[KeyPOIAnnotation class]]) {
        static NSString* uLocation=@"keyPoi";
        MAAnnotationView *anView=[mapView dequeueReusableAnnotationViewWithIdentifier:uLocation];
        if (anView==nil) {
            anView=[[MAPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:uLocation];
        }
        anView.image=[UIImage imageNamed:@"img_destination"];
        anView.centerOffset=CGPointMake(0, -18);
        return anView;
    }
    
    return nil;
}

-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (updatingLocation&&self.userLocationAnnotationView!=nil) {
//        [UIView animateWithDuration:0.1 animations:^{
//            double degree=userLocation.heading.trueHeading-self.mapView.rotationDegree;
//            self.userLocationAnnotationView.transform=CGAffineTransformMakeRotation(degree*M_PI/180.0f);
//            
//        }];
    }
}

-(void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    
}

#pragma mark - AMapNaviManager Delegate
-(void)naviManager:(AMapNaviManager *)naviManager error:(NSError *)error
{
    
}
-(void)naviManager:(AMapNaviManager *)naviManager didPresentNaviViewController:(UIViewController *)naviViewController
{
    
}

-(void)naviManager:(AMapNaviManager *)naviManager didDismissNaviViewController:(UIViewController *)naviViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)naviManagerOnCalculateRouteSuccess:(AMapNaviManager *)naviManager
{
    
}

-(void)naviManager:(AMapNaviManager *)naviManager onCalculateRouteFailure:(NSError *)error
{
    
}

-(void)naviManagerNeedRecalculateRouteForYaw:(AMapNaviManager *)naviManager
{
    
}

-(void)naviManager:(AMapNaviManager *)naviManager didStartNavi:(AMapNaviMode)naviMode
{
    
}

-(void)naviManagerDidEndEmulatorNavi:(AMapNaviManager *)naviManager
{
    
}

-(void)naviManagerOnArrivedDestination:(AMapNaviManager *)naviManager
{
    
}

-(void)naviManager:(AMapNaviManager *)naviManager onArrivedWayPoint:(int)wayPointIndex
{
    
}

-(void)naviManager:(AMapNaviManager *)naviManager didUpdateNaviLocation:(AMapNaviLocation *)naviLocation
{
    
}

-(void)naviManager:(AMapNaviManager *)naviManager didUpdateNaviInfo:(AMapNaviInfo *)naviInfo
{
    
}

-(BOOL)naviManagerGetSoundPlayState:(AMapNaviManager *)naviManager
{
    return 0;
}

-(void)naviManager:(AMapNaviManager *)naviManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType
{
    NSLog(@"playNaviSoundString:{%ld:%@}", (long)soundStringType, soundString);
    
    if (soundStringType == AMapNaviSoundTypePassedReminder)
    {
        //用系统自带的声音做简单例子，播放其他提示音需要另外配置
        AudioServicesPlaySystemSound(1009);
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            if (!self.isStop&&_iFlySpeechSynthesizer) {
                [_iFlySpeechSynthesizer startSpeaking:soundString];
            }
        });
    }
}

-(void)naviManagerDidUpdateTrafficStatuses:(AMapNaviManager *)naviManager
{
    
}

#pragma mark - iFlySpeechSynthesizer Delegate
-(void)onCompleted:(IFlySpeechError *)error
{
    
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status==kCLAuthorizationStatusAuthorizedAlways||status==kCLAuthorizationStatusAuthorizedWhenInUse) {
        [locManager startUpdatingLocation];
    }
    
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
}

@end

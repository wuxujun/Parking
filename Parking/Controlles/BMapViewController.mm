//
//  BMapViewController.m
//  Parking
//
//  Created by xujunwu on 14-7-12.
//  Copyright (c) 2014年 ___Hongkui___. All rights reserved.
//

#import "BMapViewController.h"
#import "SIAlertView.h"
#import <AudioToolbox/AudioToolbox.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import "SearchViewController.h"
#import "POIAnnotation.h"
#import "CustPOIAnnotation.h"
#import "KeyPOIAnnotation.h"
#import "UIImage+TextMask.h"

@interface BMapViewController ()<CLLocationManagerDelegate>
{
    CLLocationManager       *locManager;
    IFlyRecognizerView      *mIFlyRecognizerView;
    
    NSString                *voiceResult;
    
}

@property (nonatomic,strong)MAAnnotationView *userLocationAnnotationView;

@end

@implementation BMapViewController
@synthesize cityCode=_cityCode;

- (void)viewDidLoad
{
    [super viewDidLoad];
    voiceResult=@"";
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
    self.networkEngine=[[HNetworkEngine alloc]initWithHostName:nil customHeaderFields:nil];
    
    [self initMapView];
    [self initIFlySpeech];
    [self initIFlyRecognizer];
}

-(void)initIFlyRecognizer
{
    if(mIFlyRecognizerView==nil){
        mIFlyRecognizerView=[[IFlyRecognizerView alloc] initWithCenter:CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT/2.0)];
        mIFlyRecognizerView.delegate=self;
    }
}

-(void)startIFlyRecognizer
{
    [mIFlyRecognizerView setParameter:@"domain" forKey:@"iat"];
    [mIFlyRecognizerView setParameter:@"asr_ppt" forKey:@"0"];
    [mIFlyRecognizerView setParameter:@"sample_rate" forKey:@"16000"];
    [mIFlyRecognizerView setParameter:@"vad_eos" forKey:@"500"];
    [mIFlyRecognizerView setParameter:@"vad_bos" forKey:@"2000"];
    [mIFlyRecognizerView start];
}

- (void)initMapView
{
    if (self.mapView == nil)
    {
        self.mapView = [[MAMapView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    self.mapView.frame = self.view.bounds;
    self.mapView.delegate = self;
}

-(void)initIFlySpeech
{
    if (self.iFlySpeechSynthesizer==nil) {
        _iFlySpeechSynthesizer=[IFlySpeechSynthesizer sharedInstance];
        
    }
    _iFlySpeechSynthesizer.delegate=self;
    
}

//-(UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}
//
//-(BOOL)prefersStatusBarHidden
//{
//    return NO;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    _mapView.delegate=self;
    _mapView.showsUserLocation=NO;
    _mapView.userTrackingMode=MAUserTrackingModeNone;
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
    if (overlay==mapView.userLocationAccuracyCircle) {
        MACircleView *aview=[[MACircleView alloc]initWithCircle:overlay];
        aview.lineWidth=2.0;
        aview.strokeColor=[UIColor lightGrayColor];
        aview.fillColor=[UIColor colorWithRed:1 green:0 blue:0 alpha:3];
        return aview;
    }
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
    return nil;
}

-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (updatingLocation&&self.userLocationAnnotationView!=nil) {
//        [UIView animateWithDuration:0.1 animations:^{
//            double degree=userLocation.heading.trueHeading-self.mapView.rotationDegree;
//            self.userLocationAnnotationView.transform=CGAffineTransformMakeRotation(degree*M_PI/180.0f);
        
//        }];
    }
}

-(void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    
}

#pragma mark - iFlySpeechSynthesizer Delegate
#pragma mark - IFlySpeechSynthesizerDelegate
-(void)onCompleted:(IFlySpeechError *)error
{
    
}

-(void)onSpeakBegin
{
    
}

-(void)onBufferProgress:(int)progress message:(NSString *)msg
{
    
}

-(void)onSpeakProgress:(int)progress
{
    
}

#pragma mark - IFlyRecognizerViewDelegate
-(void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast
{
    HLog(@"%@",resultArray);
    NSMutableString *result=[[NSMutableString alloc]init];
    NSDictionary* dic=[resultArray objectAtIndex:0];
    for(NSString* key in dic){
        if ([[dic objectForKey:key] isEqualToString:@"100"]) {
            NSData *data = [key dataUsingEncoding:NSUTF8StringEncoding];
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([[json objectForKey:@"sn"] intValue]==1) {
                id ws=[json objectForKey:@"ws"];
                if ([ws isKindOfClass:[NSArray class]]) {
                    for(int i=0;i<[ws count];i++){
                        id cw=[[ws objectAtIndex:i] objectForKey:@"cw"];
                        if ([cw isKindOfClass:[NSArray class]]) {
                            for (int j=0; j<[cw count]; j++) {
                                [result appendFormat:@"%@",[[cw objectAtIndex:j] objectForKey:@"w"]];
                            }
                        }
                    }
                }
                voiceResult=[NSString stringWithFormat:@"%@",result];
                [mIFlyRecognizerView cancel];
//
            }
        }
    }
}

-(void)onError:(IFlySpeechError *)error
{
    HLog(@"%@    -->%d",error.errorDesc,error.errorCode);
    HLog(@"%@",voiceResult);
    if (voiceResult.length>0) {
        [self searchForVoiceKeyword:[NSString stringWithFormat:@"%@",voiceResult]];
    }
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

-(void)searchForVoiceKeyword:(NSString *)keyword
{
    SearchViewController* dController=[[SearchViewController alloc]init];
    dController.searchType=1;
    dController.searchKeyword=keyword;
    [self.navigationController pushViewController:dController animated:YES];
    
}

#pragma mark - 网络请求成功返回提示，及下步操作
-(void)alertRequestResult:(NSString*)message
{
    SIAlertView *alertView=[[SIAlertView alloc]initWithTitle:nil andMessage:message];
    [alertView addButtonWithTitle:@"2秒后自动关闭" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView){
        [alertView dismissAnimated:YES];
    }];
    [alertView show];
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [alertView dismissAnimated:YES];
    });
    
}

@end

//
//  HomeViewController.m
//  Parking
//
//  Created by xujunwu on 14-7-11.
//  Copyright (c) 2014年 ___Hongkui___. All rights reserved.
//

#import "HomeViewController.h"
#import "UIViewController+KeyboardAnimation.h"
#import "AppDelegate.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import <QuartzCore/QuartzCore.h>
#import "UserDefaultHelper.h"
#import "SearchAViewController.h"
#import "LoginViewController.h"
#import "UserViewController.h"
#import "DoomViewController.h"
#import "RecordViewController.h"
#import "TrafficViewContrller.h"
#import "SettingViewController.h"
#import "IntroductionController.h"
#import "FeedbackViewController.h"
#import "AboutViewController.h"
#import "NoticeViewController.h"
#import "PayViewController.h"
#import "ServiceViewController.h"
#import "PointViewController.h"

#import "CustPOIAnnotation.h"
#import "POIAnnotation.h"
#import "KeyPOIAnnotation.h"
#import "LineViewController.h"
#import "NaviViewController.h"
#import "DetailViewController.h"

#import "HomeInfoView.h"
#import "HomeInfoViewController.h"
#import "CustNavigationController.h"
#import "SearchViewController.h"
#import "ListViewController.h"
#import "CustLayerPopup.h"
#import "SubmitLayerPopup.h"
#import "ShareQRCodeView.h"
#import "StringUtil.h"
#import "BListViewController.h"
#import "DBHelper.h"
#import "DBManager.h"
#import "AppConfig.h"
#import "PoiInfoEntity.h"

#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>

#import <AudioToolbox/AudioToolbox.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import "HCurrentUserContext.h"

#import "POIAnnotation.h"
#import "CustPOIAnnotation.h"
#import "KeyPOIAnnotation.h"
#import "TPOIAnnotation.h"

#import "SIAlertView.h"
#import "UIImage+TextMask.h"
#import "MBProgressHUD.h"
#import "UIView+LoadingView.h"

@interface HomeViewController ()<CLLocationManagerDelegate,DMLazyScrollViewDelegate,HomeInfoViewControllerDelegate,CustLayerPopupDelegate,SubmitLayerPopupDelegate,ShareQRCodeViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    CLLocationManager   *locManager;
    MBProgressHUD       *loadingHUD;
    
    NSString*       currentCityCode;
    NSString*       currentAdCode;
    NSString*       currentAddress;
    double          currentLatitude;
    double          currentLongitude;
    UIButton        * btnLocation;
    UIButton        * btnTraffice;
    UIButton        * btnLayer;
    UIButton        * btnSubmit;
    UIButton        * btnClear;
    
    UIButton        * btnZoomMax;
    UIButton        * btnZoomMin;
    
    
    UIButton        * btnVoice;
    UIButton        * btnSearch;
    UIView          * mFooterView;
    DMLazyScrollView    *mFooterScrollView;
    NSMutableArray      *viewControllerArray;
    
    NSMutableArray      *data;
    NSMutableArray      *keyPois;
    NSString            *currentSearchKeyword;
    BOOL                locationFinished;
    BOOL                searchKeyword;
    BOOL                bLoading;
    BOOL                bMoveing;
    BOOL                bShowKeyword;
    BOOL                bQueryGeo;
    BOOL                bLocalSearch;
    BOOL                bFirstOrTarget;
    BOOL                bSearchResult;
    
    BOOL                bFirstVoice;
    
    AMapGeoPoint        *lastAMapGeoPoint;
    
    int                 dataTypeLayer;
    NSInteger           sourceType;
    NSInteger           currentPage;
    NSInteger           maxCount;
    
    
    NSString        *fileName;
    NSString        *filePath;
}

@property(nonatomic,strong)AMapSearchAPI    *searchAPI;
@property(nonatomic,strong)CustLayerPopup*  layerPopup;
@property(nonatomic,strong)SubmitLayerPopup* submitPopup;
@property(nonatomic,strong)ShareQRCodeView *  sharePopup;

@property (nonatomic,strong)MAAnnotationView *userKeyAnnotationView;

@property(nonatomic,strong)AMapNaviViewController   *naviViewController;

@property(nonatomic,weak)NSLayoutConstraint     *bottomSpace;
@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    data=[[NSMutableArray alloc] init];
    keyPois=[[NSMutableArray alloc]init];
    viewControllerArray=[[NSMutableArray alloc] initWithCapacity:10];
    for (NSUInteger k=0 ; k<10; ++k) {
        [viewControllerArray addObject:[NSNull null]];
    }
    currentSearchKeyword=@"停车场";
    bLoading=NO;
    locationFinished=NO;
    bMoveing=NO;
    bShowKeyword=NO;
    bFirstVoice=NO;
    bQueryGeo=NO;  //YES 查询当前所有区域
    sourceType=0;
    bLocalSearch=NO;
    bFirstOrTarget=NO;
    bSearchResult=NO;
    maxCount=0;
    if (IOS_VERSION_7_OR_ABOVE) {
        self.navigationController.navigationBar.barTintColor=DEFAULT_NAVIGATION_BACKGROUND_COLOR;
    }
    if (TARGET_IPHONE_SIMULATOR) {
        locationFinished=YES;
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
    currentCityCode=@"";
    currentAdCode=@"330702";
    currentAddress=@"";
    currentPage=0;
    
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"default_common_list_icon_normal"] style:UIBarButtonItemStylePlain target:self action:@selector(showList:)];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_menu_icon"] style:UIBarButtonItemStylePlain target:(CustNavigationController*)self.navigationController action:@selector(showMenu)];
    
    self.searchAPI=[[AMapSearchAPI alloc]initWithSearchKey:AMAP_KEY Delegate:self];
    
    
    [self configMapView];
    
    [self initMapViewTool];
    [self initCenterSearch];
    [self initFooterView];
    

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"123");
    dataTypeLayer=[[UserDefaultHelper objectForKey:CONF_CURRENT_LAYER_TYPE] intValue];
    [self resetMapButton];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"1234");
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadLocalData];
}

-(void)loadLocalData
{
    int mapToList=[[UserDefaultHelper objectForKey:CONF_MAP_TO_LIST] intValue];
    int listToMap=[[UserDefaultHelper objectForKey:CONF_LIST_TO_MAP] intValue];
    if (mapToList==1||listToMap==1) {
        [self readDBData];
    }
}

-(void)readDBData
{
    [data removeAllObjects];
    NSMutableArray* poiAnnotations=[[NSMutableArray alloc] init];
    NSArray* array=[[DBManager getInstance]queryPoiInfo:@"0" forType:[UserDefaultHelper objectForKey:CONF_PARKING_MAP_TYPE]];
    if ([array count]>0) {
        int idx=0;
        for (PoiInfoEntity *entity in array) {
            
            NSDictionary* dict=[NSDictionary dictionaryWithObjectsAndKeys:entity.title,@"title",entity.poiId,@"poiId",entity.typeDes,@"typeDes",entity.address,@"address",[NSString stringWithFormat:@"%d",entity.distance],@"distance",entity.latitude,@"latitude",entity.longitude,@"longitude",[NSString stringWithFormat:@"%d",entity.dataType],@"dataType",[NSString stringWithFormat:@"%d",(idx+1)],@"idx",entity.charge,@"charge",entity.chargeDetail,@"chargeDetail",@"0",@"price",[NSString stringWithFormat:@"%d",entity.totalCount],@"totalCount",[NSString stringWithFormat:@"%d",entity.freeCount],@"freeCount",[NSString stringWithFormat:@"%d",entity.sourceType],@"sourceType",entity.cityCode,@"cityCode",entity.adCode,@"adCode",entity.freeStatus,@"freeStatus", nil];
//            HLog(@"%d   ===> %d   %@   %@   %d   %@ <==> %@",entity.idx,idx,entity.poiId,entity.title,entity.distance,entity.latitude,entity.longitude);
            [data addObject:dict];
            if (entity.sourceType==0) {
                [poiAnnotations addObject:[[POIAnnotation alloc] initWithPoiInfoEntity:entity index:idx isSelected:NO]];
            }else{
                [poiAnnotations addObject:[[CustPOIAnnotation alloc] initWithDictionary:dict index:idx isSelected:NO]];
            }
            idx++;
        }
    }
    [self.mapView addAnnotations:poiAnnotations];
    if (bFirstOrTarget) {
        bMoveing=YES;
        [self.mapView showAnnotations:poiAnnotations animated:bFirstOrTarget];
        bMoveing=YES;
    }
    bFirstOrTarget=NO;
    [self reloadFooterData];
}

-(void)resetMapButton
{
    BOOL isSubmit=[[UserDefaultHelper objectForKey:PRE_MAP_SUBMIT] boolValue];
    if (!isSubmit) {
        [btnSubmit setHidden:YES];
        [btnClear setFrame:btnSubmit.frame];
    }else{
        [btnSubmit setHidden:NO];
        CGRect frame=btnSubmit.frame;
        frame.origin.y+=40;
        [btnClear setFrame:frame];
    }
    BOOL isZoom=[[UserDefaultHelper objectForKey:PRE_MAP_ZOOM] boolValue];
    [btnZoomMax setHidden:!isZoom];
    [btnZoomMin setHidden:!isZoom];
    
    BOOL isVoiceType=[[UserDefaultHelper objectForKey:PRE_VOICE_TYPE] boolValue];
    if (isVoiceType) {
        [self.iFlySpeechSynthesizer setParameter:@"xiaoyu" forKey:[IFlySpeechConstant VOICE_NAME]];
    }else{
        [self.iFlySpeechSynthesizer setParameter:@"xiaoyan" forKey:[IFlySpeechConstant VOICE_NAME]];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)configMapView
{
    self.mapView.delegate = self;
    
    self.mapView.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view insertSubview:self.mapView atIndex:0];
    self.mapView.showsUserLocation = YES;
}

-(void)initFooterView
{
    if (mFooterView==nil) {
        mFooterView=[[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-120, self.view.frame.size.width, 100.0)];
        [self.view  addSubview:mFooterView];
    }
    
    if (loadingHUD==nil) {
        loadingHUD=[[MBProgressHUD alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-100)/2, 30, 100, 40)];
//        loadingHUD.labelText=@"加载中...";
//        loadingHUD.mode=MBProgressHUDModeIndeterminate;
        
        loadingHUD.margin=10.0f;
        loadingHUD.cornerRadius=4.0f;
        [mFooterView addSubview:loadingHUD];
    }
    [loadingHUD show:YES];
    
    if (mFooterScrollView==nil) {
        mFooterScrollView=[[DMLazyScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100.0)];
        [mFooterScrollView setEnableCircularScroll:NO];
        [mFooterScrollView setAutoPlay:NO];
        mFooterScrollView.controlDelegate=self;
        [mFooterView addSubview:mFooterScrollView];
    }
    mFooterScrollView.numberOfPages=0;
    __weak __typeof(&*self)weakSel=self;
    mFooterScrollView.dataSource=^(NSUInteger index){
        return [weakSel controllerAtIndex:index];
    };
}


-(void)tipsTitle:(NSString*)title
{
    if (loadingHUD) {
        [loadingHUD hide:YES];
        loadingHUD.mode=MBProgressHUDModeText;
        loadingHUD.labelText=title;
        loadingHUD.labelFont=[UIFont systemFontOfSize:12.0f];
        loadingHUD.graceTime=2.0f;
        loadingHUD.taskInProgress=YES;
        [loadingHUD show:YES];
    }
}
-(void)showHUD
{
    if (loadingHUD) {
        loadingHUD.graceTime=0.0;
        loadingHUD.taskInProgress=NO;
        loadingHUD.mode=MBProgressHUDModeIndeterminate;
        loadingHUD.labelText=@"";
        [loadingHUD show:YES];
    }
}

-(void)initCenterSearch
{
    UIView* center=[[UIView alloc]initWithFrame:CGRectMake(60, 6, self.view.frame.size.width-120, 32)];
    [center setBackgroundColor:[UIColor whiteColor]];
    [center.layer setBorderColor:[[UIColor grayColor] CGColor] ];
    [center.layer setBorderWidth:0.5f];
    [center.layer setMasksToBounds:YES];
    [center.layer setCornerRadius:4.0f ];
    
    btnSearch=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, center.frame.size.width-40, center.frame.size.height)];
    [btnSearch.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [btnSearch setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btnSearch setTitle:@"搜索目的地" forState:UIControlStateNormal];
    UIImageView* searchIV=[[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 22, 22)];
    [searchIV setImage:[UIImage imageNamed:@"default_main_search_icon_normal"]];
    [btnSearch addSubview:searchIV];
    [btnSearch addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
    [center addSubview:btnSearch];
    
    btnVoice=[[UIButton alloc]initWithFrame:CGRectMake(center.frame.size.width-50, 0, 40, 32)];
    [btnVoice setImage:[UIImage imageNamed:@"default_main_voice_icon_normal"] forState:UIControlStateNormal];
    [btnVoice setImage:[UIImage imageNamed:@"default_main_voice_icon_highlighted"] forState:UIControlStateHighlighted];
    [btnVoice addTarget:self action:@selector(voice:) forControlEvents:UIControlEventTouchUpInside];
    [center addSubview:btnVoice];
    self.navigationItem.titleView=center;
}

-(IBAction)voice:(id)sender
{
    [self startIFlyRecognizer];
}

-(void)initMapViewTool
{
    float leftPadding=self.view.frame.size.width-42;
    btnLocation=[[UIButton alloc]initWithFrame:CGRectMake(leftPadding, 70, 38, 38)];
    [btnLocation setBackgroundImage:[UIImage imageNamed:@"default_main_gpsbutton_background_normal"] forState:UIControlStateNormal];
    [btnLocation setImage:[UIImage imageNamed:@"default_main_gpsnormalbutton_image_normal"] forState:UIControlStateNormal];
    [btnLocation addTarget:self action:@selector(showLocation:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnLocation];
    
    btnLayer=[[UIButton alloc] initWithFrame:CGRectMake(leftPadding, 110, 38, 38)];
    [btnLayer setBackgroundImage:[UIImage imageNamed:@"default_main_gpsbutton_background_normal"] forState:UIControlStateNormal];
    [btnLayer setImage:[UIImage imageNamed:@"default_main_layer_btn_normal"] forState:UIControlStateNormal];
    [btnLayer addTarget:self action:@selector(showLayerSet:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnLayer];
    
    btnTraffice=[[UIButton alloc]  initWithFrame:CGRectMake(leftPadding, 150, 38, 38)];
    [btnTraffice setBackgroundImage:[UIImage imageNamed:@"default_main_gpsbutton_background_normal"] forState:UIControlStateNormal];
    [btnTraffice setImage:[UIImage imageNamed:@"default_main_trafficlayer_close_normal"] forState:UIControlStateNormal];
    [btnTraffice setTag:0];
    [btnTraffice addTarget:self action:@selector(onTraffice:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnTraffice];
    
    btnSubmit=[[UIButton alloc]  initWithFrame:CGRectMake(leftPadding, 190, 38, 38)];
    [btnSubmit setBackgroundImage:[UIImage imageNamed:@"default_main_gpsbutton_background_normal"] forState:UIControlStateNormal];
    [btnSubmit setImage:[UIImage imageNamed:@"default_feedback_icon_map_mergeentrance"] forState:UIControlStateNormal];
    [btnSubmit addTarget:self action:@selector(onSubmit:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnSubmit];
    
    btnClear=[[UIButton alloc]  initWithFrame:CGRectMake(leftPadding, 230, 38, 38)];
    [btnClear setBackgroundImage:[UIImage imageNamed:@"default_main_gpsbutton_background_normal"] forState:UIControlStateNormal];
    [btnClear setImage:[UIImage imageNamed:@"default_generalsearch_onceback"] forState:UIControlStateNormal];
    [btnClear addTarget:self action:@selector(onClear:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnClear];
    [btnClear setHidden:YES];
    
    btnZoomMax=[[UIButton alloc]initWithFrame:CGRectMake(leftPadding, 280, 38, 38)];
    [btnZoomMax setTag:0];
    [btnZoomMax setImage:[UIImage imageNamed:@"default_main_zoombtn_zoomin_normal"] forState:UIControlStateNormal];
    [btnZoomMax setImage:[UIImage imageNamed:@"default_main_zoombtn_zoomin_disable"] forState:UIControlStateDisabled];
    [btnZoomMax addTarget:self action:@selector(onMapZoom:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnZoomMax];
    btnZoomMin=[[UIButton alloc]initWithFrame:CGRectMake(leftPadding, 318, 38, 38)];
    [btnZoomMin setTag:1];
    [btnZoomMin setImage:[UIImage imageNamed:@"default_main_zoombtn_zoomout_normal"] forState:UIControlStateNormal];
    [btnZoomMin setImage:[UIImage imageNamed:@"default_main_zoombtn_zoomout_disable"] forState:UIControlStateDisabled];
    [btnZoomMin addTarget:self action:@selector(onMapZoom:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnZoomMin];

}

-(IBAction)onClear:(id)sender
{
    [self clearAllAnnotationPOI];
    [btnClear setHidden:YES];
}

-(IBAction)onSubmit:(id)sender
{
    [self.submitPopup dismissPopover];
    self.submitPopup=[[SubmitLayerPopup alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT/2.0, SCREEN_WIDTH, SCREEN_HEIGHT/2.0) delegate:self];
    [self.submitPopup.layer setBorderWidth:0.3f];
    [self.submitPopup.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [self.submitPopup showInView:self.view];
//    self.bottomSpace=[NSLayoutConstraint constraintWithItem:self.submitPopup attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-20];
//    [self.view addConstraint:self.bottomSpace];
    
    [self an_subscribeKeyboardWithAnimations:^(CGRect keyboardRect, NSTimeInterval duration, BOOL isShowing) {
        if (isShowing) {
            CGRect frame =self.submitPopup.frame;
            frame.origin.y=CGRectGetHeight(keyboardRect)-44.0;
            [self.submitPopup setFrame:frame];
        } else {
            CGRect frame =self.submitPopup.frame;
            frame.origin.y=SCREEN_HEIGHT/2.0;
            [self.submitPopup setFrame:frame];
        }
        [self.view layoutIfNeeded];
    } completion:nil];
}



-(IBAction)onMapZoom:(id)sender
{
    UIButton*   btn=(UIButton*)sender;
    float level=self.mapView.zoomLevel;
    float minLevel=self.mapView.minZoomLevel;
    float maxLevel=self.mapView.maxZoomLevel;
    int newLevel=level;
    switch (btn.tag) {
        case 0:
        {
            newLevel=level+1;
            if (level+1>maxLevel) {
                newLevel=maxLevel;
            }
            bMoveing=YES;
            [self.mapView setZoomLevel:newLevel animated:YES];
        }
            break;
        default:
        {
            newLevel=level-1;
            if (newLevel-1<minLevel) {
                newLevel=minLevel;
            }
            bMoveing=YES;
            [self.mapView setZoomLevel:newLevel animated:YES];
        }
            break;
    }
}

-(IBAction)onTraffice:(id)sender
{
    UIButton* btn=(UIButton*)sender;
    if (![self.mapView isShowTraffic]) {
        [btn setImage:[UIImage imageNamed:@"default_main_trafficlayer_open_normal"] forState:UIControlStateNormal];
        [self.mapView setShowTraffic:YES];
    }else{
        [btn setImage:[UIImage imageNamed:@"default_main_trafficlayer_close_normal"] forState:UIControlStateNormal];
        [self.mapView setShowTraffic:NO];
    }
}

-(void)onShareQRCode
{
    [self.sharePopup dismissPopover];
    self.sharePopup=[[ShareQRCodeView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT/2.0, SCREEN_WIDTH, SCREEN_HEIGHT/2.0) delegate:self];
    [self.sharePopup.layer setBorderWidth:0.3f];
    [self.sharePopup.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [self.sharePopup showInView:self.view];
}

-(void)onClickShareMore:(ShareQRCodeView *)view
{
    [self.sharePopup dismissPopover];
    NSMutableArray  *ls=[[NSMutableArray alloc] init];
    [ls addObject:UMShareToSina];
    [ls addObject:UMShareToTencent];
    if ([TencentOAuth iphoneQQInstalled]&&[TencentOAuth iphoneQQSupportSSOLogin]) {
        [ls addObject:UMShareToQQ];
        [ls addObject:UMShareToQzone];
    }
    if ([WXApi isWXAppInstalled]) {
        [ls addObject:UMShareToWechatSession];
        [ls addObject:UMShareToWechatTimeline];
    }
    [ls addObject:UMShareToSms];
    [ls addObject:UMShareToEmail];
    
    [UMSocialSnsService presentSnsIconSheetView:self appKey:UMENG_APPKEY shareText:APPSHARE_CONTENT shareImage:[UIImage imageNamed:@"ic_share_app"] shareToSnsNames:ls delegate:self];
}

-(IBAction)showLocation:(id)sender
{
    if (self.mapView) {
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(currentLatitude, currentLongitude)];
    }
}

-(IBAction)showLayerSet:(id)sender
{
    UIButton* btn=(UIButton*)sender;
    [self.layerPopup dismissMenuPopover];
    self.layerPopup=[[CustLayerPopup alloc]initWithFrame:CGRectMake(5, btn.frame.origin.y+btn.frame.size.height, self.view.frame.size.width-10, 256) delegate:self];
    [self.layerPopup.layer setCornerRadius:8.0f];
    [self.layerPopup.layer setMasksToBounds:YES];
    [self.layerPopup.layer setBorderWidth:0.3f];
    [self.layerPopup.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [self.layerPopup showInView:self.view];
    
}

-(IBAction)showList:(id)sender
{
    HLog(@"%d",dataTypeLayer);
    [UserDefaultHelper setObject:@"0" forKey:CONF_LIST_TO_MAP];
    [UserDefaultHelper setObject:@"1" forKey:CONF_MAP_TO_LIST];
    ListViewController* dController=[[ListViewController alloc]init];
    dController.sourceType=sourceType;
    dController.dataType=[[UserDefaultHelper objectForKey:CONF_CURRENT_LAYER_TYPE] intValue];
    [dController setStartPoint:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",currentLatitude],@"latitude",[NSString stringWithFormat:@"%f",currentLongitude],@"longitude", nil]];
    [self.navigationController pushViewController:dController animated:YES];
}

-(IBAction)search:(id)sender
{
    [UserDefaultHelper setObject:@"0" forKey:CONF_MAP_TO_LIST];
    [UserDefaultHelper setObject:@"0" forKey:CONF_LIST_TO_MAP];
    SearchViewController *dController=[[SearchViewController alloc]init];
    dController.searchType=0;
    dController.cityCode=currentCityCode;
    [dController setStartPoint:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",currentLatitude],@"latitude",[NSString stringWithFormat:@"%f",currentLongitude],@"longitude", nil]];
    [self.navigationController pushViewController:dController animated:YES];
}

-(UIViewController*)controllerAtIndex:(NSInteger)index
{
    if (index>=[data count]||index<0) {
        return nil;
    }
    
    id res=[viewControllerArray objectAtIndex:index%10];
    NSDictionary* dict=[data objectAtIndex:index];
    if (res==[NSNull null]) {
        HomeInfoViewController* viewController=[[HomeInfoViewController alloc]init];
        viewController.infoDict=dict;
        viewController.delegate=self;
        [viewControllerArray replaceObjectAtIndex:index%10 withObject:viewController];
        return viewController;
    }
    [(HomeInfoViewController*)res setInfoDict:dict];
    [(HomeInfoViewController*)res refresh];
    return res;
}

-(void)playSpeechForMsg:(NSString*)msg
{
    BOOL isVoice=[[UserDefaultHelper objectForKey:PRE_VOICE] boolValue];
    if (!isVoice) {
        return;
    }
    [self.iFlySpeechSynthesizer startSpeaking:msg];
}

-(void)playSpeech:(NSDictionary*)dict
{
    
    NSMutableString *msg=[[NSMutableString alloc]init];
    [msg appendString:@"为您推荐附近停车场"];
    [msg appendFormat:@"%@",[dict objectForKey:@"title"]];
//    NSString* addr=[dict objectForKey:@"address"];
//    if (addr==(id)[NSNull null]||addr.length==0) {
//        
//    }else{
//        [msg appendFormat:@"%@",addr];
//    }
    
    NSInteger free=[[dict objectForKey:@"freeCount"] integerValue];
    NSInteger total=[[dict objectForKey:@"totalCount"] integerValue];
    if (free>0&&total>0) {
        [msg appendFormat:@"剩余车位%d个,总车位%d个",free,total];
    }else{
        if (total>0) {
            [msg appendFormat:@"总车位%d个",total];
        }
    }
    [self playSpeechForMsg:msg];
    
}

- (void)lazyScrollView:(DMLazyScrollView *)pagingView currentPageChanged:(NSInteger)currentPageIndex
{
    if (currentPageIndex==-1) {
        return;
    }
    currentPage=currentPageIndex;
    if (currentPageIndex<[data count]) {
        NSDictionary* dic=[data objectAtIndex:currentPageIndex];
        HLog(@"--->%d---%d-->%@--->%@",currentPageIndex,[dic objectForKey:@"idx"],[dic objectForKey:@"poiId"],[dic objectForKey:@"title"]);
        HLog(@"---->%@  ---->%@",[dic objectForKey:@"latitude"],[dic objectForKey:@"longitude"]);
        [self selectPOIAnnotationForIndex:currentPageIndex];
        if (currentPageIndex>0) {
            bSearchResult=NO;
        }
        if(!bSearchResult) {
            bMoveing=YES;
            [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake([[dic objectForKey:@"latitude"] floatValue], [[dic objectForKey:@"longitude"] floatValue]) animated:YES];
        }
    }
    

}

-(void)reloadFooterData
{
//    dataTypeLayer=[[UserDefaultHelper objectForKey:CONF_CURRENT_LAYER_TYPE] intValue];
//    BOOL isVoice=[[UserDefaultHelper objectForKey:PRE_VOICE] boolValue];
    if ([data count]>0) {
        if ([data count]>maxCount) {
            [mFooterScrollView setNumberOfPages:[data count]];
            maxCount=[data count];
        }
        [mFooterScrollView setHidden:NO];
        [mFooterScrollView setPage:0 animated:NO];
    }else{
        [mFooterScrollView setHidden:YES];
    }
    
    if(self.userLocationAnnotation){
        [self.mapView addAnnotation:self.userLocationAnnotation];
    }
    
    if([[self.mapView overlays] count]>0){
        [self.mapView removeOverlays:[self.mapView overlays]];
    }
    
//    for (UIView* view in mFooterScrollView.subviews) {
//        if ([view isKindOfClass:[HomeInfoView class]]) {
//            [view removeFromSuperview];
//        }
//    }
//    HomeInfoView* item;
//    for (int i=0; i<[data count]; i++) {
//        item=[[HomeInfoView alloc]initWithFrame:CGRectMake(i*self.view.frame.size.width, 0, self.view.frame.size.width, 100) delegate:self];
//        [item setInfoDict:[data objectAtIndex:i]];
//        [mFooterScrollView addSubview:item];
//        if (i==0&&!bFirstVoice&&dataTypeLayer==1&&currentAddress.length>0&&isVoice) {
//            NSDictionary* dic=[data objectAtIndex:0];
//            NSString* msg=[NSString stringWithFormat:@"您当前所在位置:%@,为您推荐附近停车场 %@ 地址 %@",currentAddress,[dic objectForKey:@"title"],[dic objectForKey:@"address"]];
//            [self.iFlySpeechSynthesizer startSpeaking:msg];
//            bFirstVoice=YES;
//        }
//    }
//    mFooterScrollView.contentSize=CGSizeMake(mFooterScrollView.frame.size.width*[data count], mFooterScrollView.frame.size.height);
//    [mFooterScrollView scrollRectToVisible:CGRectMake(0, 0, mFooterScrollView.frame.size.width, mFooterScrollView.frame.size.height) animated:YES];
    
    [btnClear setHidden:YES];
//    if ([data count]>0) {
//        [btnClear setHidden:NO];
//    }
    
}

-(void)onSubmitContent:(SubmitLayerPopup *)view forIndex:(NSInteger)tag
{
    if (tag==2) {
        PointViewController* dController=[[PointViewController alloc]init];
        dController.infoDict=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",currentLatitude],@"latitude",[NSString stringWithFormat:@"%f",currentLongitude],@"longitude", nil];
        [self.navigationController pushViewController:dController animated:YES];
    }else if(tag==3){
        [self showImagePicker:YES];
    }else{
        [self.submitPopup dismissPopover];
    }
}

-(void)showSubmitMessage:(NSString *)msg
{
    [self alertRequestResult:msg];
}

-(void)showImagePicker:(BOOL)isCamera
{
    BOOL hasCamera=[UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (!hasCamera) {
        [self alertRequestResult:@"对不起,拍照功能不支持"];
    }
    UIImagePickerController* dController=[[UIImagePickerController alloc]init];
    if(IOS_VERSION_8_OR_ABOVE){
        dController.modalPresentationStyle=UIModalPresentationCurrentContext;
    }
    dController.delegate=self;
    if (hasCamera&&isCamera) {
        dController.sourceType=UIImagePickerControllerSourceTypeCamera;
    }else{
        dController.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    }
    if (!dController.isBeingPresented) {
        [self presentViewController:dController animated:YES completion:nil];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   
    
    NSString* mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYYMMddhhmmss"];
    NSString *curTime=[formatter stringFromDate:[NSDate date] ];
    if ([mediaType isEqualToString:@"public.image"]) {
        fileName=[NSString stringWithFormat:@"%@.jpg",curTime];
        filePath=[NSString stringWithFormat:@"%@/%@",[[AppConfig getInstance] getPhotoFilePath],fileName];
        UIImage* image=[info objectForKey:UIImagePickerControllerOriginalImage];
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:UIImageJPEGRepresentation(image, 0.5) attributes:nil];
        NSDictionary* dict=[NSDictionary dictionaryWithObjectsAndKeys:@"4",@"dataType",fileName,@"image", nil];
        if (self.submitPopup) {
            [self.submitPopup setPhotoInfo:dict];
        }
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - HomeInfoViewControllerDelegate
-(void)onHomeInfoViewClicked:(NSDictionary *)infoDict type:(int)aType
{
    switch (aType) {
        case 1:
        {
            //附近
            SearchViewController* dController=[[SearchViewController alloc]init];
            dController.searchType=2;
            dController.startPoint=infoDict;
            [self.navigationController pushViewController:dController animated:YES];
            break;
        }
        case 2:{
            //Line
            LineViewController* dController=[[LineViewController alloc]init];
            dController.lineType=1;
            [dController setStartPoint:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",currentLatitude],@"latitude",[NSString stringWithFormat:@"%f",currentLongitude],@"longitude", nil]];
            [dController setEndPoint:infoDict];
            [self.navigationController pushViewController:dController animated:YES];
            break;
        }
        case 3:
        {
            //Navi
            NaviViewController* dController=[[NaviViewController alloc]init];
            [dController setNaviType:1];
            [dController setStartPoint:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",currentLatitude],@"latitude",[NSString stringWithFormat:@"%f",currentLongitude],@"longitude", nil]];
            [dController setEndPoint:infoDict];
            [self.navigationController pushViewController:dController animated:YES];
            break;
        }
        case 11:
        {
            if (dataTypeLayer==3) {
                BListViewController* dController=[[BListViewController alloc]init];
                dController.infoDict=infoDict;
                [dController setStartPoint:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",currentLatitude],@"latitude",[NSString stringWithFormat:@"%f",currentLongitude],@"longitude", nil]];
                [self.navigationController pushViewController:dController animated:YES];
            }else{
                DetailViewController* dController=[[DetailViewController alloc]init];
                dController.dataType=dataTypeLayer;
                [dController setStartPoint:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",currentLatitude],@"latitude",[NSString stringWithFormat:@"%f",currentLongitude],@"longitude", nil]];
                HLog(@"%@",infoDict);
                [dController setInfoDict:infoDict];
                [self.navigationController pushViewController:dController animated:YES];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - CLLocationManagerDelegate
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (updatingLocation) {
        currentLongitude=userLocation.coordinate.longitude;
        currentLatitude=userLocation.coordinate.latitude;
//        HLog(@"%.6f   %.6f",currentLatitude,currentLongitude);
        int mapToList=[[UserDefaultHelper objectForKey:CONF_MAP_TO_LIST] intValue];
        int listToMap=[[UserDefaultHelper objectForKey:CONF_LIST_TO_MAP] intValue];
        if (mapToList==0&&listToMap==0) {
            if (!locationFinished) {
                locationFinished=YES;
                bFirstOrTarget=YES;
                [self searchForKeyword:[NSDictionary dictionaryWithObjectsAndKeys:@"停车场",@"title",@"1",@"dataType", nil]];
            }
            [self searchForGeo];
            [UserDefaultHelper setObject:[NSNumber numberWithDouble:currentLatitude] forKey:CONF_LOCATION_LATITUDE];
            [UserDefaultHelper setObject:[NSNumber numberWithDouble:currentLongitude] forKey:CONF_LOCATION_LONGITUDE];
            if (!TARGET_IPHONE_SIMULATOR) {
                lastAMapGeoPoint=[AMapGeoPoint locationWithLatitude:currentLatitude longitude:currentLongitude];
            }
//        HLog(@"%@  %.8f  %.8f",userLocation.title,userLocation.coordinate.longitude,userLocation.coordinate.latitude);
        }
    }
}

-(void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    id<MAAnnotation> annotation=view.annotation;
    if ([annotation isKindOfClass:[POIAnnotation class]]) {
        POIAnnotation* poi=(POIAnnotation*)annotation;
        
//        [self selectPOIAnnotationForIndex:poi.index];
        if ([data count]>0) {
            [mFooterScrollView setPage:poi.index animated:YES];
        }
    }else if ([annotation isKindOfClass:[CustPOIAnnotation class]]) {
        CustPOIAnnotation* poi=(CustPOIAnnotation*)annotation;
//        [self selectPOIAnnotationForIndex:poi.index];
        
        NSDictionary* dict=poi.dict;
        HLog(@"%d  %@  %@",[dict objectForKey:@"idx"],[dict objectForKey:@"poiId"],[dict objectForKey:@"title"],[dict objectForKey:@"distance"]);
        if ([[dict objectForKey:@"dataType"] intValue]==1&&[[dict objectForKey:@"sourceType"] intValue]==1) {
            [self playSpeech:dict];
        }
        if ([data count]>0) {
            [mFooterScrollView setPage:poi.index animated:YES];
        }
    }
}

-(void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    id<MAAnnotation> annotation=view.annotation;
    if ([annotation isKindOfClass:[POIAnnotation class]]) {
        
    }
}

-(MAAnnotationView*)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation{
    if ([annotation isKindOfClass:[POIAnnotation class]]) {
        POIAnnotation* poi=(POIAnnotation*)annotation;
        NSString* uLocation=[NSString stringWithFormat:@"custPoi-%d",poi.index];
        MAPinAnnotationView *anView=(MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:uLocation];
        if (anView==nil) {
            anView=[[MAPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:uLocation];
        }
        NSString *img=@"ic_parking";
        if (dataTypeLayer==2) {
            img=@"ic_bicycle_blue";
        }else if(dataTypeLayer==3){
            img=@"ic_bus_blue";
        }
        if (poi.isSelected) {
            img=@"ic_parking_s2";
            if (dataTypeLayer==2) {
                img=@"ic_bicycle_blue_s2";
            }else if(dataTypeLayer==3){
                img=@"ic_bus_blue_s2";
            }
        }

        anView.image=[UIImage imageNamed:img];
        if (poi.isSelected) {
            CGRect frame=anView.frame;
            frame.size.width=frame.size.width*1.5;
            frame.size.height=frame.size.height*1.5;
            anView.frame=frame;
            [anView setContentMode:UIViewContentModeScaleToFill];
        }
        anView.centerOffset=CGPointMake(0, -18);
        return anView;
    }
    if ([annotation isKindOfClass:[CustPOIAnnotation class]]) {
        CustPOIAnnotation* poi=(CustPOIAnnotation*)annotation;
        NSString* uLocation=[NSString stringWithFormat:@"custPoi"];
        MAPinAnnotationView *anView=(MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:uLocation];
        if (anView==nil) {
            anView=[[MAPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:uLocation];
        }
        NSString *img=@"ic_parking_green";
        NSString* price=[poi.dict objectForKey:@"charge"];
        if ([price isEqual:@""]) {
            price=@"2";
        }
        NSString* status=[poi.dict objectForKey:@"freeStatus"];
        img=[[AppConfig getInstance] getMapIcon:dataTypeLayer isSelect:poi.isSelected fee:price status:status];
//        HLog(@"%@  ==>%@",poi.dict,img);
        anView.image=[UIImage imageNamed:img];
        if (poi.isSelected) {
            [anView setHighlighted:YES];
            CGRect frame=anView.frame;
            frame.size.width=frame.size.width*1.5;
            frame.size.height=frame.size.height*1.5;
            anView.frame=frame;
        }
        anView.centerOffset=CGPointMake(0, -18);
        return anView;
    }
    if ([annotation isKindOfClass:[TPOIAnnotation class]]) {
        TPOIAnnotation* poi=(TPOIAnnotation*)annotation;
        NSString* uLocation=[NSString stringWithFormat:@"TPoi"];
        MAPinAnnotationView *anView=(MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:uLocation];
        if (anView==nil) {
            anView=[[MAPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:uLocation];
        }
        NSString *img=@"default_generalsearch_poi_1_highlight";
        img=[[AppConfig getInstance] getTMapIcon:poi.index isSelect:poi.isSelected];
        anView.image=[UIImage imageNamed:img];
        anView.centerOffset=CGPointMake(0, -18);
        return anView;
    }
//    if ([annotation isKindOfClass:[KeyPOIAnnotation class]]) {
//        static NSString* uLocation=@"keyPoi";
//        MAAnnotationView *anView=[mapView dequeueReusableAnnotationViewWithIdentifier:uLocation];
//        if (anView==nil) {
//            anView=[[MAPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:uLocation];
//        }
//        anView.image=[UIImage imageNamed:@"img_destination"];
//        anView.centerOffset=CGPointMake(0, -18);
//        return anView;
//    }
    return [super mapView:mapView viewForAnnotation:annotation];
}

- (void)mapView:(MAMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    MAMapPoint  point1=MAMapPointForCoordinate(CLLocationCoordinate2DMake(lastAMapGeoPoint.latitude, lastAMapGeoPoint.longitude));
    MAMapPoint  point2=MAMapPointForCoordinate(mapView.centerCoordinate);
    CLLocationDistance distance=MAMetersBetweenMapPoints(point1, point2);
}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    MAMapPoint  point1=MAMapPointForCoordinate(CLLocationCoordinate2DMake(lastAMapGeoPoint.latitude, lastAMapGeoPoint.longitude));
    MAMapPoint  point2=MAMapPointForCoordinate(mapView.centerCoordinate);
    CLLocationDistance distance=MAMetersBetweenMapPoints(point1, point2);
//    [self searchForGeo:[AMapGeoPoint locationWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude]];
//    HLog(@"......%.6f   %.6f  %d    %d",mapView.centerCoordinate.latitude,mapView.centerCoordinate.longitude,bMoveing,distance);
    BOOL isShow=[[[NSUserDefaults standardUserDefaults] objectForKey:CONF_PARKING_MOVE_SHOW] boolValue];
    if (distance>100&&isShow&&locationFinished&&!bMoveing) {
        if (!bLoading) {
            [self serarchForMapCenter:[AMapGeoPoint locationWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude]];
            bLoading=YES;
        }
        lastAMapGeoPoint=[AMapGeoPoint locationWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude];
    }
    bMoveing=NO;
}

#pragma mark - AMapSearchDelegate

-(void)searchRequest:(id)request didFailWithError:(NSError *)error
{
    HLog(@"%@   %@",[request class],error);
}

-(void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)response
{
    bLoading=NO;
    if (response.pois.count==0) {
        [self tipsTitle:@"无数据"];
        return;
    }
    [data removeAllObjects];
    NSMutableArray* poiAnnotations=[NSMutableArray arrayWithCapacity:response.pois.count];
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI* p,NSUInteger idx,BOOL *stop){
        
            NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:p.name,@"title",p.uid,@"poiId",p.type,@"typeDes",p.address,@"address",[NSNumber numberWithInteger:p.distance],@"distance",[NSString stringWithFormat:@"%f",p.location.latitude],@"latitude",[NSString stringWithFormat:@"%f",p.location.longitude],@"longitude",@"0",@"dataType",[NSString stringWithFormat:@"%d",(idx+1)],@"idx",p.citycode,@"cityCode",p.adcode,@"adCode",@"0",@"totalCount",@"0",@"freeCount",@"0",@"freeStatus",@"0",@"chargeDetail",@"0",@"charge",@"0",@"price",@"0",@"sourceType", nil];
            [data addObject:dict];
        if (searchKeyword) {
            [poiAnnotations addObject:[[TPOIAnnotation alloc] initWithPOI:p index:idx isSelected:NO]];
        }else{
            [poiAnnotations addObject:[[POIAnnotation alloc] initWithPOI:p index:idx isSelected:NO]];
        }
    }];
    sourceType=0;
    [self insertDB];
    [self.mapView addAnnotations:poiAnnotations];
    if (bFirstOrTarget) {
        bMoveing=YES;
        [self.mapView showAnnotations:poiAnnotations animated:bFirstOrTarget];
    }
    bFirstOrTarget=NO;
    bSearchResult=YES;
    [self reloadFooterData];
}

-(void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    BOOL isVoice=[[UserDefaultHelper objectForKey:PRE_VOICE] boolValue];
    if (response.regeocode) {
        if (bQueryGeo) {
            currentCityCode=response.regeocode.addressComponent.citycode;
            currentAdCode=response.regeocode.addressComponent.adcode;
        }else{
            currentAddress=[NSString stringWithFormat:@"%@",response.regeocode.formattedAddress];
            currentCityCode=response.regeocode.addressComponent.citycode;
            if ([data count]>0&&!bFirstVoice&&dataTypeLayer==1&&currentAddress.length>0&&isVoice) {
                NSDictionary* dic=[data objectAtIndex:0];
                NSString* msg=[NSString stringWithFormat:@"您当前所在位置:%@,为您推荐附近停车场 %@ 地址 %@",currentAddress,[dic objectForKey:@"title"],[dic objectForKey:@"address"]];
                [self playSpeechForMsg:msg];
                bFirstVoice=YES;
            }
        }
    }
}
#pragma mark - Search Local Data
-(void)searchLocalAMapPOI:(NSDictionary*)poi
{
    NSString* requestUrl=[NSString stringWithFormat:@"%@downgrade_service/near_parking_list",kHttpUrl];
    if (dataTypeLayer==1) {
        requestUrl=[NSString stringWithFormat:@"%@downgrade_service/near_parking_list",kHttpUrl];
    }else{
        requestUrl=[NSString stringWithFormat:@"%@bikeStation_list",kHttpUrl];
    }
    bLocalSearch=YES;
    NSMutableDictionary* params=[[NSMutableDictionary alloc]init];
    [params setObject:@"0" forKey:@"fetchType"];
    [params setObject:[NSString stringWithFormat:@"%@",[poi objectForKey:@"longitude"]] forKey:@"X"];
     [params setObject:[NSString stringWithFormat:@"%@",[poi objectForKey:@"latitude"]] forKey:@"Y"];
//    NSString* parkingType=[UserDefaultHelper objectForKey:CONF_PARKING_MAP_TYPE];
//    if (![parkingType isEqualToString:@"0"]) {
//        
//    }
    NSString* parkingCharge=[UserDefaultHelper objectForKey:CONF_PARKING_MAP_CHARGE];
    if (![parkingCharge isEqualToString:@"0"]) {
        [params setObject:parkingCharge forKey:@"charge"];
    }
    NSString* parkingStatus=[UserDefaultHelper objectForKey:CONF_PARKING_MAP_STATUS];
    if (![parkingStatus isEqualToString:@"0"]) {
        [params setObject:parkingStatus forKey:@"freeStatus"];
    }
    
//    [params setObject:poi.name forKey:@"searchText"];
//    [params setObject:[poi objectForKey:@"adCode"] forKey:@"region"];
    [self.networkEngine postOperationWithURLString:requestUrl params:params success:^(MKNetworkOperation *completedOperation, id result) {
        bLoading=NO;
//        HLog(@"%@",result);
        if([[result objectForKey:@"status"] intValue]==200){
            if (dataTypeLayer==1) {
                [self parserParkingResponse:result];
            }else{
                [self parserBicycleResponse:result];
            }
        }
    } error:^(NSError *error) {
        HLog(@"%@",error);
        bLoading=NO;
    }];
}
-(void)parserParkingResponse:(NSDictionary*)result
{
    id list=[result objectForKey:@"parkingList"];
    [data removeAllObjects];
    if ([list isKindOfClass:[NSArray class]]) {
        for (int i=0; i<[list count]; i++) {
            NSDictionary* dc=[list objectAtIndex:i];
            NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:[dc objectForKey:@"parkName"],@"title",[dc objectForKey:@"parkId"],@"poiId",[dc objectForKey:@"parkType"],@"typeDes",[dc objectForKey:@"address"],@"address",[self caclDistance:dc],@"distance",[self caclGpsValue:[dc objectForKey:@"y"] forType:0],@"latitude",[self caclGpsValue:[dc objectForKey:@"x"] forType:1],@"longitude",@"1",@"dataType",[NSString stringWithFormat:@"%d",(i+1)],@"idx",[dc objectForKey:@"charge"],@"charge",[dc objectForKey:@"chargeDetail"],@"chargeDetail",@"0",@"price",[dc objectForKey:@"totalCount"],@"totalCount",[dc objectForKey:@"freeCount"],@"freeCount",[dc objectForKey:@"freeStatus"],@"freeStatus",@"1",@"sourceType",@"0579",@"cityCode",@"330702",@"adCode", nil];
            [data addObject:dict];
        }
        sourceType=1;
        bSearchResult=YES;
        [self insertDB];
        [self readDBData];
    }
}

#pragma mark - 计算距离
-(NSString*)caclDistance:(NSDictionary*)dict
{
    MAMapPoint point1 = MAMapPointForCoordinate(CLLocationCoordinate2DMake([[UserDefaultHelper objectForKey:CONF_CURRENT_TARGET_LATITUDE] floatValue],[[UserDefaultHelper objectForKey:CONF_CURRENT_TARGET_LONGITUDE] floatValue]));
    MAMapPoint point2 = MAMapPointForCoordinate(CLLocationCoordinate2DMake([[self caclGpsValue:[dict objectForKey:@"y"] forType:0] floatValue],[[self caclGpsValue:[dict objectForKey:@"x"] forType:1] floatValue]));
    //计算距离
    CLLocationDistance distance = MAMetersBetweenMapPoints(point1,point2);
    NSString* distanceStr=[NSString stringWithFormat:@"%.0f",distance];
    return distanceStr;
}

-(BOOL)pointIsVisibleMapRect:(CustPOIAnnotation*) annotation
{
    MAMapPoint point=MAMapPointForCoordinate(annotation.coordinate);
    BOOL isContains=MAMapRectContainsPoint(self.mapView.visibleMapRect, point);
    return isContains;
}

-(void)parserBicycleResponse:(NSDictionary*)result
{
//    HLog(@"%@",result);
    id list=[result objectForKey:@"bsList"];
    [data removeAllObjects];
    if ([list isKindOfClass:[NSArray class]]) {
        for (int i=0; i<[list count]; i++) {
            NSDictionary* dc=[list objectAtIndex:i];
            NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:[dc objectForKey:@"bsName"],@"title",[dc objectForKey:@"bsId"],@"poiId",@"公共自行车",@"typeDes",[dc objectForKey:@"address"],@"address",[self caclDistance:dc],@"distance",[self caclGpsValue:[dc objectForKey:@"y"] forType:0],@"latitude",[self caclGpsValue:[dc objectForKey:@"x"] forType:1],@"longitude",@"2",@"dataType",[NSString stringWithFormat:@"%d",(i+1)],@"idx",@"0",@"charge",@"0",@"chargeDetail",@"0",@"price",[dc objectForKey:@"totalCount"],@"totalCount",[dc objectForKey:@"freeCount"],@"freeCount",@"0",@"freeStatus",@"1",@"sourceType",@"0579",@"cityCode",@"330702",@"adCode", nil];
            [data addObject:dict];
        }
        sourceType=1;
        bSearchResult=YES;
        [self insertDB];
        [self readDBData];
    }
}

-(NSString*)caclGpsValue:(NSString* )val forType:(NSInteger)type
{
//    NSString* sp=@"-";
//    NSRange range=[val rangeOfString:sp];
//    int location=range.location;
//    int lenght=range.length;
    NSMutableString* newString=[[NSMutableString alloc]initWithCapacity:val.length];
    for (int i=val.length-1; i>=0; i--) {
        unichar ch=[val characterAtIndex:i];
        [newString appendFormat:@"%c",ch];
    }
    float value=0.0;
    if (type==0) {
        value=(30000000+[newString integerValue])/1000000.0;
    }else{
        value=(120000000+[newString integerValue])/1000000.0;
    }
    
    return [NSString stringWithFormat:@"%.6f",value];
}

-(void)searchForAMapPOI:(AMapPOI*)poi
{
    currentCityCode=[NSString stringWithFormat:@"%@",poi.citycode];
    currentAdCode=poi.adcode;
    [btnSearch setTitle:poi.name forState:UIControlStateNormal];
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude)];
    [keyPois removeAllObjects];
    bShowKeyword=NO;
    if ([data count]>0) {
        [mFooterScrollView setPage:-1 animated:NO];
    }
    [data removeAllObjects];
    [self clearAllAnnotationPOI];
    searchKeyword=NO;
    bMoveing=YES;
    bFirstOrTarget=YES;
    KeyPOIAnnotation *pointAnnotation=[[KeyPOIAnnotation alloc] initWithPOI:poi];
    [keyPois addObject:pointAnnotation];
    [self.mapView addAnnotations:keyPois];
    [self.mapView showAnnotations:keyPois animated:YES];
    [UserDefaultHelper setObject:[NSString stringWithFormat:@"%.6f",poi.location.latitude] forKey:CONF_CURRENT_TARGET_LATITUDE];
    [UserDefaultHelper setObject:[NSString stringWithFormat:@"%.6f",poi.location.longitude] forKey:CONF_CURRENT_TARGET_LONGITUDE];
    
    if ([currentCityCode isEqualToString:@"0579"]&&dataTypeLayer<3) {
        HLog(@"search city %@   %d",currentCityCode,dataTypeLayer);
        [self reloadFooterData];
        [self searchLocalAMapPOI:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%.6f",poi.location.longitude],@"longitude",[NSString stringWithFormat:@"%.6f",poi.location.latitude],@"latitude",poi.adcode,@"adCode", nil]];
        return;
    }
    
    bLocalSearch=NO;
    AMapPlaceSearchRequest * poiRequest=[[AMapPlaceSearchRequest alloc]init];
    poiRequest.searchType=AMapSearchType_PlaceAround;
    poiRequest.sortrule=1;
    poiRequest.offset=10;
    if (dataTypeLayer==1) {
        poiRequest.keywords=@"停车场";
    }else if(dataTypeLayer==2){
        poiRequest.keywords=@"公共自行车";
    }else{
        poiRequest.keywords=@"公交站";
    }
    poiRequest.location=[AMapGeoPoint locationWithLatitude:poi.location.latitude longitude:poi.location.longitude];
    poiRequest.requireExtension=YES;
    [self.searchAPI AMapPlaceSearch:poiRequest];
    
}

-(void)serarchForMapCenter:(AMapGeoPoint*)point
{
    if([data count]>0){
        [mFooterScrollView setPage:-1 animated:NO];
    }
    [data removeAllObjects];
    [self clearAllAnnotationPOI];
    if (bLocalSearch) {
        currentCityCode=@"0579";
    }else{
    }
    [self showHUD];
    HLog(@"search city %@   %d",currentCityCode,dataTypeLayer);
    if ([currentCityCode isEqualToString:@"0579"]&&dataTypeLayer<3) {
        [self reloadFooterData];
        [self searchLocalAMapPOI:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%.6f",point.longitude],@"longitude",[NSString stringWithFormat:@"%.6f",point.latitude],@"latitude",currentAdCode,@"adCode", nil]];
        return;
    }
    HLog(@"%@,  %.6f  %.6f",currentSearchKeyword,point.latitude,point.longitude);
    
    AMapPlaceSearchRequest * poiRequest=[[AMapPlaceSearchRequest alloc]init];
    poiRequest.searchType=AMapSearchType_PlaceAround;
    poiRequest.sortrule=1;
    poiRequest.offset=10;
//    poiRequest.radius=500;
    poiRequest.keywords=currentSearchKeyword;
    poiRequest.location=point;
    poiRequest.requireExtension=NO;
    [self.searchAPI AMapPlaceSearch:poiRequest];
}

-(void)viewSwitch:(CustLayerPopup *)view forIndex:(int)idx
{
    dataTypeLayer=idx;
    searchKeyword=NO;
    switch (dataTypeLayer) {
        case 1:
        {
            currentSearchKeyword=@"停车场";
            break;
        }
        case 2:{
            currentSearchKeyword=@"公共自行车";
            break;
        }
        case 3:{
            currentSearchKeyword=@"公交站";
            break;
        }
        default:
            break;
    }
    [self.layerPopup dismissMenuPopover];
    bLoading=YES;
    [self serarchForMapCenter:[AMapGeoPoint locationWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude]];
}

-(void)viewStatusSwitch:(CustLayerPopup *)view forIndex:(NSInteger)idx
{
    
    [self.layerPopup dismissMenuPopover];
}

-(void)viewTypeSwitch:(CustLayerPopup *)view forIndex:(NSInteger)idx
{
    
    [self.layerPopup dismissMenuPopover];
}

-(void)viewChargeSwitch:(CustLayerPopup *)view forIndex:(NSInteger)idx
{
    
    [self.layerPopup dismissMenuPopover];
}

#pragma - mark Public

-(void)openViewController:(int)type
{
    switch (type) {
        case 0:{
            SearchAViewController* dController=[[SearchAViewController alloc]init];
            [self.navigationController pushViewController:dController animated:YES];
            break;
        }
        case 1:{
            TrafficViewContrller* dController=[[TrafficViewContrller alloc] init];
            [self.navigationController pushViewController:dController animated:YES];
            break;
        }
        case 2:{
            DoomViewController* dController=[[DoomViewController alloc] init];
            [self.navigationController pushViewController:dController animated:YES];
            break;
        }
        case 3:{
            RecordViewController* dController=[[RecordViewController alloc] init];
            [self.navigationController pushViewController:dController animated:YES];
            break;
        }
        case 4:
        {
            SettingViewController* dController=[[SettingViewController alloc]init];
            [self.navigationController pushViewController:dController animated:YES];
            break;
        }
        case 5:
        {
            IntroductionController *dController=[[IntroductionController alloc]init];
            dController.dataType=1;
            [self.navigationController pushViewController:dController animated:YES];
            break;
        }
        case 6:
        {
            [self onShareQRCode];
//            [[UMSocialDataService defaultDataService] postSNSWithTypes:@[] content:APPSHARE_CONTENT image:nil location:nil urlResource:nil completion:^(UMSocialResponseEntity *response) {
//                if (response.responseCode==UMSResponseCodeSuccess) {
//                    
//                }
//            }];
            
            break;
        }
        case 7:
        {
            if ([[HCurrentUserContext sharedInstance] uid]) {
                FeedbackViewController* dController=[[FeedbackViewController alloc]init];
                [self.navigationController pushViewController:dController animated:YES];
            }else{
                LoginViewController* dController=[[LoginViewController alloc] init];
                [self.navigationController pushViewController:dController animated:YES];
            }
            break;
        }
        case 8:
        {
            AboutViewController* dController=[[AboutViewController alloc]init];
            [self.navigationController pushViewController:dController animated:YES];
            break;
        }
        case 100:
        {
            HCurrentUserContext *userContext = [HCurrentUserContext sharedInstance];
            if (userContext.uid) {
                UserViewController* dController=[[UserViewController alloc]init];
                [self.navigationController pushViewController:dController animated:YES];
            }else{
                LoginViewController* dController=[[LoginViewController alloc]init];
                [self.navigationController pushViewController:dController animated:YES];
            }
            break;
        }
        case 101:
        {
            PayViewController* dController=[[PayViewController alloc]init];
            [self.navigationController pushViewController:dController animated:YES];
            break;
        }
        case 102:
        {
            ServiceViewController* dController=[[ServiceViewController alloc]init];
            [self.navigationController pushViewController:dController animated:YES];
            break;
        }
        case 103:
        {
            NoticeViewController* dController=[[NoticeViewController alloc]init];
            [self.navigationController pushViewController:dController animated:YES];
            break;
        }
        default:
            break;
    }
}

-(void)searchForGeo
{
    AMapReGeocodeSearchRequest* request=[[AMapReGeocodeSearchRequest alloc]init];
    request.searchType=AMapSearchType_ReGeocode;
    request.location=[AMapGeoPoint locationWithLatitude:currentLatitude longitude:currentLongitude];
    request.requireExtension=YES;
    [self.searchAPI AMapReGoecodeSearch:request];
}

-(void)searchForGeo:(AMapGeoPoint*)point
{
    bQueryGeo=YES;
    AMapReGeocodeSearchRequest* request=[[AMapReGeocodeSearchRequest alloc]init];
    request.searchType=AMapSearchType_ReGeocode;
    request.location=point;
    request.requireExtension=YES;
    [self.searchAPI AMapReGoecodeSearch:request];
}

-(void)searchForKeyword:(NSDictionary *)dict
{
    HLog(@"%@",[dict objectForKey:@"title"]);
    [data removeAllObjects];
    [self clearAllAnnotationPOI];
    searchKeyword=NO;
    dataTypeLayer=[[dict objectForKey:@"dataType"] intValue];
    if(dataTypeLayer==0){
        searchKeyword=YES;
    }
    currentSearchKeyword=[dict objectForKey:@"title"];
    [btnSearch setTitle:[dict objectForKey:@"title"] forState:UIControlStateNormal];
    AMapPlaceSearchRequest * poiRequest=[[AMapPlaceSearchRequest alloc]init];
    poiRequest.searchType=AMapSearchType_PlaceAround;
    poiRequest.sortrule=1;
    poiRequest.offset=10;
    poiRequest.keywords=[dict objectForKey:@"title"];
    poiRequest.location=[AMapGeoPoint locationWithLatitude:currentLatitude longitude:currentLongitude];
    poiRequest.requireExtension=NO;
    [self.searchAPI AMapPlaceSearch:poiRequest];
}

-(void)searchNearbyForKeyword:(NSDictionary *)dict
{
    [data removeAllObjects];
    [self clearAllAnnotationPOI];
    searchKeyword=YES;  //周边搜索
    dataTypeLayer=0;
    currentSearchKeyword=[dict objectForKey:@"keyword"];
    [btnSearch setTitle:[dict objectForKey:@"keyword"] forState:UIControlStateNormal];
    AMapPlaceSearchRequest * poiRequest=[[AMapPlaceSearchRequest alloc]init];
    poiRequest.searchType=AMapSearchType_PlaceAround;
    poiRequest.sortrule=1;
    poiRequest.offset=10;
    poiRequest.keywords=[dict objectForKey:@"keyword"];
    poiRequest.location=[AMapGeoPoint locationWithLatitude:[[dict objectForKey:@"latitude"] floatValue] longitude:[[dict objectForKey:@"longitude"] floatValue]];
    poiRequest.requireExtension=NO;
    [self.searchAPI AMapPlaceSearch:poiRequest];
}

-(void)searchHisForKeyword:(SearchHisEntity *)entity
{
    currentCityCode=entity.cityCode;
    currentAdCode=entity.adCode;
    [btnSearch setTitle:entity.keyword forState:UIControlStateNormal];
    bShowKeyword=NO;
    if ([data count]>0) {
        [mFooterScrollView setPage:-1 animated:NO];
    }
    [data removeAllObjects];
    [self clearAllAnnotationPOI];
    searchKeyword=NO;
    bLocalSearch=NO; 
    bMoveing=YES;
    bFirstOrTarget=YES;
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake([entity.latitude doubleValue], [entity.longitude doubleValue])];
    [keyPois removeAllObjects];
    KeyPOIAnnotation *pointAnnotation=[[KeyPOIAnnotation alloc] initWithSearchHisEntity:entity];
    [keyPois addObject:pointAnnotation];
    [self.mapView addAnnotations:keyPois];
    [self.mapView showAnnotations:keyPois animated:YES];
    
    [UserDefaultHelper setObject:[NSString stringWithFormat:@"%@",entity.latitude] forKey:CONF_CURRENT_TARGET_LATITUDE];
    [UserDefaultHelper setObject:[NSString stringWithFormat:@"%@",entity.longitude] forKey:CONF_CURRENT_TARGET_LONGITUDE];
    
    if ([currentCityCode isEqualToString:@"0579"]&&dataTypeLayer<3) {
        HLog(@"search city %@   %d",currentCityCode,dataTypeLayer);
        [self reloadFooterData];
        [self searchLocalAMapPOI:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",entity.longitude],@"longitude",[NSString stringWithFormat:@"%@",entity.latitude],@"latitude",entity.adCode,@"adCode", nil]];
        return;
    }
    AMapPlaceSearchRequest * poiRequest=[[AMapPlaceSearchRequest alloc]init];
    poiRequest.searchType=AMapSearchType_PlaceAround;
    poiRequest.sortrule=1;
    poiRequest.offset=10;
    if (dataTypeLayer==1) {
        poiRequest.keywords=@"停车场";
    }else if(dataTypeLayer==2){
        poiRequest.keywords=@"公共自行车";
    }else{
        poiRequest.keywords=@"公交站";
    }
    poiRequest.location=[AMapGeoPoint locationWithLatitude:[entity.latitude doubleValue] longitude:[entity.longitude doubleValue]];
    poiRequest.requireExtension=YES;
    [self.searchAPI AMapPlaceSearch:poiRequest];
}

-(void)searchForAMapTip:(AMapTip *)tip
{
    HLog(@"%@  %@  %@",tip.name,tip.adcode,tip.district);
    [[DBManager getInstance] insertOrUpdateSearchHistory:[NSDictionary dictionaryWithObjectsAndKeys:tip.name,@"keyword",[NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]],@"insertTime",@"0",@"hisType",tip.adcode,@"adCode", nil]];
    [self clearAllAnnotationPOI];
    searchKeyword=YES;
    bFirstOrTarget=YES;
    currentSearchKeyword=tip.name;
    [btnSearch setTitle:tip.name forState:UIControlStateNormal];
    AMapPlaceSearchRequest * poiRequest=[[AMapPlaceSearchRequest alloc]  init];
    poiRequest.searchType=AMapSearchType_PlaceKeyword;
    poiRequest.keywords=tip.name;
    poiRequest.sortrule=1;
    poiRequest.offset=10;
    poiRequest.city=@[tip.adcode];
    poiRequest.requireExtension=YES;
    [self.searchAPI AMapPlaceSearch:poiRequest];
}

-(void)onMapSelectDone:(NSDictionary *)dict
{
    if (self.submitPopup) {
        [self.submitPopup setMapPoint:dict];
    }
}

-(NSString*)getPointImage:(NSDictionary*)dict forSelect:(BOOL)flag
{
    NSString *img=@"ic_parkging";
    int dType=[[dict objectForKey:@"dataType"] intValue];
    int sType=[[dict objectForKey:@"sourceType"] intValue];
    if (sType==1) {
        NSString *img=@"ic_parking_green";
        NSString* price=[dict objectForKey:@"charge"];
        if ([price isEqual:@""]) {
            price=@"2";
        }
        NSString* status=[dict objectForKey:@"freeStatus"];
        img=[[AppConfig getInstance] getMapIcon:dType isSelect:flag fee:price status:status];
    }else{
        if (dType==2) {
            img=@"ic_bicycle_blue";
        }else if(dType==3){
            img=@"ic_bus_blue";
        }
        if (flag) {
            img=@"ic_parking_s2";
            if (dType==2) {
                img=@"ic_bicycle_blue_s2";
            }else if(dType==3){
                img=@"ic_bus_blue_s2";
            }
        }
    }
    return img;
}

-(void)selectPOIAnnotationForIndex:(NSInteger)idx
{
    NSArray* array=self.mapView.annotations;
    NSMutableArray *annotations=[[NSMutableArray alloc]init];
    NSMutableArray *annotationsDel=[[NSMutableArray alloc]init];
    for ( int i=0;i<[array count];i++) {
        id <MAAnnotation> an=[array objectAtIndex:i];
        if ([an isKindOfClass:[POIAnnotation class]]) {
            POIAnnotation *poiA=(POIAnnotation*)an;
            if ([poiA index]==idx) {
                if (poiA.entity) {
                    POIAnnotation *poi=[[POIAnnotation alloc]initWithPoiInfoEntity:poiA.entity index:idx isSelected:YES];
                    [annotations addObject:poi];
                }else{
                    POIAnnotation *poi=[[POIAnnotation alloc]initWithPOI:poiA.poi index:idx isSelected:YES];
                    [annotations addObject:poi];
                }
            }else{
                if (poiA.entity) {
                    POIAnnotation *poi=[[POIAnnotation alloc]initWithPoiInfoEntity:poiA.entity index:[poiA index] isSelected:NO];
                    [annotations addObject:poi];
                }else{
                    POIAnnotation *poi=[[POIAnnotation alloc]initWithPOI:poiA.poi index:[poiA index] isSelected:NO];
                    [annotations addObject:poi];
                }
                
            }
        }else if ([an isKindOfClass:[CustPOIAnnotation class]]) {
            CustPOIAnnotation* poiA=(CustPOIAnnotation*)an;
            if ([poiA index]==idx) {
                CustPOIAnnotation *poi=[[CustPOIAnnotation alloc]initWithDictionary:[poiA dict] index:idx isSelected:YES];
                [annotations addObject:poi];
            }else{
                CustPOIAnnotation *poi=[[CustPOIAnnotation alloc]initWithDictionary:[poiA dict] index:[poiA index] isSelected:NO];
                [annotations addObject:poi];
            }
        }else if ([an isKindOfClass:[TPOIAnnotation class]]) {
            TPOIAnnotation *poiA=(TPOIAnnotation*)an;
            if ([poiA index]==idx) {
                if (poiA.entity) {
                    TPOIAnnotation *poi=[[TPOIAnnotation alloc]initWithPoiInfoEntity:poiA.entity index:idx isSelected:YES];
                    [annotations addObject:poi];
                }else{
                    TPOIAnnotation *poi=[[TPOIAnnotation alloc]initWithPOI:poiA.poi index:idx isSelected:YES];
                    [annotations addObject:poi];
                }
            }else{
                if (poiA.entity) {
                    TPOIAnnotation *poi=[[TPOIAnnotation alloc]initWithPoiInfoEntity:poiA.entity index:[poiA index] isSelected:NO];
                    [annotations addObject:poi];
                }else{
                    TPOIAnnotation *poi=[[TPOIAnnotation alloc]initWithPOI:poiA.poi index:[poiA index] isSelected:NO];
                    [annotations addObject:poi];
                }
            }
        }else if([an isKindOfClass:[KeyPOIAnnotation class]]){
            KeyPOIAnnotation* poiA=(KeyPOIAnnotation*)an;
            [annotations addObject:poiA];
        }
        [annotationsDel addObject:an];
    }
    [self.mapView removeAnnotations:annotationsDel];
    [self.mapView addAnnotations:annotations];
}

-(void)insertDB
{
    [[DBManager getInstance] deleteAllPoiInfo];
    for (NSDictionary* dict in data) {
        [[DBManager getInstance] insertOrUpdatePoiInfo:dict];
    }
    if ([data count]==0) {
        [self tipsTitle:@"无数据"];
    }
}

-(void)clearAllAnnotationPOI
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    if ([keyPois count]>0) {
        [self.mapView addAnnotations:keyPois];
    }
}

//-(void)clearAnnotationPOI:(NSInteger)type
//{
//    [self.mapView removeAnnotations:self.mapView.annotations];
//    return;
// 
//    NSArray* array=self.mapView.annotations;
//    NSMutableArray* annotations=[[NSMutableArray alloc]init];
//    for ( int i=0;i<[array count];i++) {
//        id <MAAnnotation> an=[array objectAtIndex:i];
//        if ([an isKindOfClass:[POIAnnotation class]]&&type==0) {
//            [annotations addObject:an];
//        }else if ([an isKindOfClass:[CustPOIAnnotation class]]&&type==1) {
//            [annotations addObject:an];
//        }else if ([an isKindOfClass:[KeyPOIAnnotation class]]&&type==1000) {
//            [annotations addObject:an];
//        }else if ([an isKindOfClass:[TPOIAnnotation class]]&&type==0) {
//            [annotations addObject:an];
//        }
//    }
//    [self.mapView removeAnnotations:annotations];
//}

@end

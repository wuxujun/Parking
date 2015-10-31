//
//  AppDelegate.m
//  Parking
//
//  Created by xujunwu on 14-7-11.
//  Copyright (c) 2014年 ___Hongkui___. All rights reserved.
//

#import "AppDelegate.h"
#import "CustNavigationController.h"
#import "StartViewController.h"
#import "IntroductionController.h"
#import "MenuViewController.h"
#import "UserDefaultHelper.h"
#import "HCurrentUserContext.h"
#import "DBHelper.h"
#import "DBManager.h"
#import "SearchHisEntity.h"
#import "Reachability.h"
#import "SIAlertView.h"
#import "StringUtil.h"

#import <AMapNaviKit/AMapNaviKit.h>
#import "iflyMSC/IFlySpeechSynthesizer.h"
#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySetting.h"
#import "iflyMSC/IFlyUserWords.h"

#import "MobClick.h"
#import "UMSocial.h"
#import "UMSocialSnsService.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaHandler.h"

#import "GAIFields.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"
static NSString *const kTrackingId=@"UA-30968675-6";
static NSString *const kAllowTracking=@"allowTracking";


@implementation AppDelegate
@synthesize rootViewController=_rootViewController;
@synthesize homeViewController=_homeViewController;


-(void)configureApiKey
{
    [AMapNaviServices sharedServices].apiKey=AMAP_KEY;
    [MAMapServices sharedServices].apiKey=AMAP_KEY;
}

- (void)configIFlySpeech
{
    [IFlySpeechUtility createUtility:[NSString stringWithFormat:@"appid=%@,timeout=%@",@"5565399b",@"20000"]];
    
    [IFlySetting setLogFile:LVL_NONE];
    [IFlySetting showLogcat:NO];
    
    // 设置语音合成的参数
//    [[IFlySpeechSynthesizer sharedInstance] setParameter:@"50" forKey:[IFlySpeechConstant SPEED]];//合成的语速,取值范围 0~100
//    [[IFlySpeechSynthesizer sharedInstance] setParameter:@"50" forKey:[IFlySpeechConstant VOLUME]];//合成的音量;取值范围 0~100
    
    // 发音人,默认为”xiaoyan”;可以设置的参数列表可参考个 性化发音人列表;
//    [[IFlySpeechSynthesizer sharedInstance] setParameter:@"xiaoyan" forKey:[IFlySpeechConstant VOICE_NAME]];
    
    // 音频采样率,目前支持的采样率有 16000 和 8000;
//    [[IFlySpeechSynthesizer sharedInstance] setParameter:@"8000" forKey:[IFlySpeechConstant SAMPLE_RATE]];
    
    // 当你再不需要保存音频时，请在必要的地方加上这行。
//    [[IFlySpeechSynthesizer sharedInstance] setParameter:nil forKey:[IFlySpeechConstant TTS_AUDIO_PATH]];
    
    self.iflyDataUploader=[IFlyDataUploader new];
    [self.iflyDataUploader setParameter:@"iat" forKey:@"subject"];
    [self.iflyDataUploader setParameter:@"userword" forKey:@"dtt"];
    IFlyUserWords* iflyUserWords=[[IFlyUserWords alloc]initWithJson:VOICE_KEYWORD];
    [self.iflyDataUploader uploadDataWithCompletionHandler:^(NSString *result, IFlySpeechError *error) {
//        NSLog(@"%@",result);
        if(![error errorCode]){
            NSLog(@"上传成功");
        }
    } name:@"userwords" data:[iflyUserWords toString] ];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [UserDefaultHelper setObject:[NSNumber numberWithInt:1] forKey:CONF_CURRENT_LAYER_TYPE];
    
    //高德地图
    [self configureApiKey];
    //科大讯飞语音
    [self configIFlySpeech];
    
    
    [DBHelper initDatabase];
    
    [self checkNetwork];
    
    [self initConfigData];
//    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
#if TARGET_IPHONE_SIMULATOR
    NSLog(@" TARGET_IPHONE_SIMULATOR is not support Notification ");
#else
    
    if (IOS_VERSION_8_OR_ABOVE) {
        NSLog(@"registerForPushNotification: For iOS >= 8.0");
        if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
            [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound|UIUserNotificationTypeBadge|UIUserNotificationTypeAlert) categories:nil]];
            [application registerForRemoteNotifications];
        }
    }else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert)];
    }
#endif

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onOpenController:) name:NOTIFICATION_OPEN_TYPE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSearchKeyword:) name:NOTIFICATION_SEARCH_KEYWORK object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSearchNearbyKeyword:) name:NOTIFICATION_SEARCH_NEARBY_KEYWORK object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSearchHisKeyword:) name:NOTIFICATION_SEARCH_HIS_KEYWORK object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSearchTip:) name:NOTIFICATION_SEARCH_TIP object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMapSelectDone:) name:NOTIFICATION_MAPSELECT_DONE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];

    NSDictionary *appDefault=@{kAllowTracking:@(YES)};
    [[NSUserDefaults standardUserDefaults]registerDefaults:appDefault];
    [GAI sharedInstance].optOut=![[NSUserDefaults standardUserDefaults] boolForKey:kAllowTracking];
    [GAI sharedInstance].dispatchInterval=20;
    //    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    [GAI sharedInstance].trackUncaughtExceptions=YES;
    self.tracker=[[GAI sharedInstance] trackerWithTrackingId:kTrackingId];
    
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName value:@"Parking"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createScreenView]build]];
    
    self.window=[[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    self.homeViewController=[[HomeViewController alloc]init];
   
    self.rootViewController=[[StartViewController alloc] init];
    self.window.rootViewController=self.rootViewController;
    self.window.tintColor=[UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

-(void)openIntroduction:(NSInteger)type
{
    for (UIView* view in self.window.subviews) {
        if ([view isKindOfClass:[UIView  class]]) {
            [view removeFromSuperview];
        }
    }
    IntroductionController* dController=[[IntroductionController alloc]init];
    dController.dataType=type;
    self.rootViewController=dController;
    self.window.rootViewController=self.rootViewController;
    [self.window makeKeyAndVisible];
}

-(void)openHomeView
{
    for (UIView* view in self.window.subviews) {
        if ([view isKindOfClass:[UIView  class]]) {
            [view removeFromSuperview];
        }
    }
    CustNavigationController *naviController=[[CustNavigationController alloc] initWithRootViewController:self.homeViewController];
    MenuViewController* menuController=[[MenuViewController alloc]init];
    REFrostedViewController *frostedViewController=[[REFrostedViewController alloc]initWithContentViewController:naviController  menuViewController:menuController];
    frostedViewController.direction=REFrostedViewControllerDirectionLeft;
    frostedViewController.liveBlurBackgroundStyle=REFrostedViewControllerLiveBackgroundStyleLight;
    frostedViewController.liveBlur=YES;
    frostedViewController.delegate=self;
    
    self.rootViewController=frostedViewController;//[[UINavigationController alloc]initWithRootViewController:homeController];
    self.window.rootViewController=self.rootViewController;
    self.window.tintColor=[UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
}

-(void)checkNetwork
{
//    Reachability * reach=[Reachability reachabilityForInternetConnection];
    Reachability* reach=[Reachability reachabilityWithHostname:@"www.163.com"];
    reach.reachableBlock=^(Reachability *reach){
       
    };
    reach.unreachableBlock=^(Reachability *reach){
        
    };
    [reach startNotifier];
}

-(void)initConfigData
{
    if (![UserDefaultHelper objectForKey:CONF_NETWORK_TYPE]) {
        [UserDefaultHelper setObject:@"0" forKey:CONF_NETWORK_TYPE];
    }
    if(![UserDefaultHelper objectForKey:PRE_FIRST_OPEN]){
        [UserDefaultHelper setObject:[NSNumber numberWithBool:true] forKey:PRE_FIRST_OPEN];
    }
    
    if (![UserDefaultHelper objectForKey:PRE_VOICE_TYPE]) {
        [UserDefaultHelper setObject:[NSNumber numberWithBool:false] forKey:PRE_VOICE_TYPE];
    }
    
    if (![UserDefaultHelper objectForKey:PRE_VOICE]) {
        [UserDefaultHelper setObject:[NSNumber numberWithBool:true] forKey:PRE_VOICE];
    }
    
    if(![UserDefaultHelper objectForKey:PRE_MAP_SUBMIT]){
        [UserDefaultHelper setObject:[NSNumber numberWithBool:false] forKey:PRE_MAP_SUBMIT];
    }
    
    if(![UserDefaultHelper objectForKey:PRE_MAP_ZOOM]){
        [UserDefaultHelper setObject:[NSNumber numberWithBool:true] forKey:PRE_MAP_ZOOM];
    }

    if(![UserDefaultHelper objectForKey:PRE_NAVI_EMULATOR]){
        [UserDefaultHelper setObject:[NSNumber numberWithBool:false] forKey:PRE_NAVI_EMULATOR];
    }

    
    if(![UserDefaultHelper objectForKey:CONF_PARKING_MOVE_SHOW]){
        [UserDefaultHelper setObject:[NSNumber numberWithBool:true] forKey:CONF_PARKING_MOVE_SHOW];
    }
    
    [UserDefaultHelper setObject:@"0" forKey:CONF_MAP_TO_LIST];
    [UserDefaultHelper setObject:@"0" forKey:CONF_LIST_TO_MAP];
    
    [UserDefaultHelper setObject:@"0" forKey:CONF_PARKING_MAP_CHARGE];
    [UserDefaultHelper setObject:@"0" forKey:CONF_PARKING_MAP_STATUS];
    [UserDefaultHelper setObject:@"0" forKey:CONF_PARKING_MAP_TYPE];
    [UserDefaultHelper setObject:@"0" forKey:CONF_PARKING_AREA_CODE];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:CONF_DATABASE_VERSION];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [MobClick startWithAppkey:UMENG_APPKEY reportPolicy:BATCH channelId:@""];
    [MobClick setAppVersion:version];
    [UMSocialData setAppKey:UMENG_APPKEY];
    
    [UMSocialQQHandler setSupportWebView:YES];
    [UMSocialQQHandler setQQWithAppId:APPID_QQ appKey:APPKEY_QQ url:APPSHARE_URL];
    
    [UMSocialWechatHandler setWXAppId:APPKEY_WEIXIN appSecret:APPSECRET_WEIXIN url:APPSHARE_URL];
    [UMSocialSinaHandler openSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
    self.networkEngine=[[HNetworkEngine alloc]initWithHostName:nil customHeaderFields:nil];
    NSString*   requestUrl=[NSString stringWithFormat:@"%@link",kHttpUrl];
    NSMutableDictionary* params=[NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:kAppId,@"appid",@"GBK",@"charset", nil]];

    [self.networkEngine postOperationWithURLString:requestUrl params:params success:^(MKNetworkOperation *completedOperation, id result) {
//        HLog(@"%@",result);
        if (result!=nil&&[result objectForKey:@"linkCode"]) {
            [UserDefaultHelper setObject:[result objectForKey:@"linkCode"] forKey:APP_REQUEST_LINKCODE];
            [UserDefaultHelper setObject:[result objectForKey:@"pubKey"] forKey:APP_REQUEST_PUBKEY];
            [self autoLogin];
        }
    } error:^(NSError *error) {
            NSLog(@"post deviceToken fail");
    }];
}

-(void)autoLogin
{
    [self onDataUpdate];
    HCurrentUserContext* userContext=[HCurrentUserContext sharedInstance];
    if (userContext.uid) {
        [userContext loginWithUserName:[UserDefaultHelper objectForKey:PRE_LOGIN_USER] password:[UserDefaultHelper objectForKey:PRE_LOGIN_PASSWORD] success:^(MKNetworkOperation *completedOperation, id result) {
            HLog(@"%@",result);
        } error:^(NSError *error) {
            HLog(@"%@",error);
        }];
    }
}

-(void)onDataUpdate
{
    NSInteger count=[[[DBManager getInstance] queryLocalPoiInfo] count];
    if (count<=0) {
        [self parkingDataRequest:@"0" forStart:0];
    }else{
        timer=[NSTimer scheduledTimerWithTimeInterval:60.0*8 target:self selector:@selector(onDataGet:) userInfo:nil repeats:YES];
    }
}

-(void)onDataGet:(NSTimer *)timer
{
    [self parkingDataRequest:@"0" forStart:0];
}

-(void)parkingDataRequest:(NSString*)region forStart:(NSInteger)start
{
    NSString* requestUrl=[NSString stringWithFormat:@"%@downgrade_service/paging_parking_list",kHttpUrl];
    NSMutableDictionary* params=[[NSMutableDictionary alloc]init];
     self.region=region;
    if (![region isEqualToString:@"0"]) {
        [params setObject:region forKey:@"region"];
    }
    [params setObject:[NSNumber numberWithInteger:start] forKey:@"startIndex"];
    [params setObject:[NSNumber numberWithInteger:100] forKey:@"getCount"];
    
    [self.networkEngine postOperationWithURLString:requestUrl params:params success:^(MKNetworkOperation *completedOperation, id result) {
        if([[result objectForKey:@"status"] intValue]==200){
            [self parserParkingResponse:result];
        }
    } error:^(NSError *error) {
        HLog(@"%@",error);
    }];
}

-(void)parserParkingResponse:(NSDictionary*)result
{
    id list=[result objectForKey:@"parkingList"];
    NSInteger startIndex=[[result objectForKey:@"startIndex"] integerValue];
    NSInteger dataCount=[[result objectForKey:@"dataCount"] integerValue];
    NSInteger getCount=[[result objectForKey:@"getCount"] integerValue];
    
    if ([list isKindOfClass:[NSArray class]]) {
        for (int i=0; i<[list count]; i++) {
            NSDictionary* dc=[list objectAtIndex:i];
            NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:[dc objectForKey:@"parkName"],@"title",[dc objectForKey:@"parkId"],@"poiId",[dc objectForKey:@"parkType"],@"typeDes",[dc objectForKey:@"address"],@"address",@"0",@"distance",[self caclGpsValue:[dc objectForKey:@"y"] forType:0],@"latitude",[self caclGpsValue:[dc objectForKey:@"x"] forType:1],@"longitude",@"1",@"dataType",[NSString stringWithFormat:@"%d",(i+1)],@"idx",[dc objectForKey:@"charge"],@"charge",[dc objectForKey:@"chargeDetail"],@"chargeDetail",@"0",@"price",[dc objectForKey:@"totalCount"],@"totalCount",[dc objectForKey:@"freeCount"],@"freeCount",[dc objectForKey:@"freeStatus"],@"freeStatus",@"1",@"sourceType",@"0579",@"cityCode",@"330702",@"adCode",[dc objectForKey:@"shopHours"],@"shopHours",[dc objectForKey:@"thumbUrl"],@"thumbUrl",[dc objectForKey:@"parkRiveType"],@"parkRiveType", nil];
            [[DBManager getInstance] insertOrUpdatePoiInfo:dict];
        }
    }
    if ((startIndex+getCount)<dataCount) {
        [self parkingDataRequest:self.region forStart:(startIndex+getCount)];
    }
    NSDateFormatter* formater=[[NSDateFormatter alloc]init];
    formater.dateFormat=@"mm-dd HH:mm:ss SSS";
    HLog(@"%@   %@  %d  %d   %d",[NSString currentTime:formater],self.region,dataCount,startIndex,getCount);
}

-(NSString*)caclGpsValue:(NSString* )val forType:(NSInteger)type
{
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

//-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
//{
//    NSLog(@"....performFetchWithCompletionHandler..");
//    [self parkingDataRequest:@"330702" forStart:0];
//    completionHandler(UIBackgroundFetchResultNewData);
//    application.applicationIconBadgeNumber+=1;
//}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Parking" action:@"Close" label:@"Close Parking" value:[NSNumber numberWithInt:2]] build]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_OPEN_TYPE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SEARCH_KEYWORK object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SEARCH_HIS_KEYWORK object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SEARCH_TIP object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SEARCH_NEARBY_KEYWORK object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_MAPSELECT_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    if (timer) {
        [timer setFireDate:[NSDate distantFuture]];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onOpenController:) name:NOTIFICATION_OPEN_TYPE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSearchKeyword:) name:NOTIFICATION_SEARCH_KEYWORK object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSearchTip:) name:NOTIFICATION_SEARCH_TIP object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSearchNearbyKeyword:) name:NOTIFICATION_SEARCH_NEARBY_KEYWORK object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSearchHisKeyword:) name:NOTIFICATION_SEARCH_HIS_KEYWORK object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMapSelectDone:) name:NOTIFICATION_MAPSELECT_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    if (timer) {
        [timer setFireDate:[NSDate distantPast]];
    }
    application.applicationIconBadgeNumber=0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [GAI sharedInstance].optOut=![[NSUserDefaults standardUserDefaults]boolForKey:kAllowTracking];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Parking" action:@"Open" label:@"Open Parking" value:[NSNumber numberWithInt:1]] build]];
   [MobClick checkUpdate];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)frostedViewController:(REFrostedViewController *)frostedViewController didRecognizePanGesture:(UIPanGestureRecognizer *)recognizer
{
    
}

-(void)frostedViewController:(REFrostedViewController *)frostedViewController willShowMenuViewController:(UIViewController *)menuViewController
{
    
}
-(void)frostedViewController:(REFrostedViewController *)frostedViewController didShowMenuViewController:(UIViewController *)menuViewController
{
    
}

-(void)frostedViewController:(REFrostedViewController *)frostedViewController willHideMenuViewController:(UIViewController *)menuViewController
{
    
}

-(void)frostedViewController:(REFrostedViewController *)frostedViewController didHideMenuViewController:(UIViewController *)menuViewController
{
    
}

-(void)onOpenController:(NSNotification*)notification
{
    NSDictionary* dict=(NSDictionary*)notification.object;
    int type=[[dict objectForKey:@"type"] intValue];
    [self.homeViewController openViewController:type];
}

-(void)onSearchKeyword:(NSNotification*)notification
{
    NSDictionary* dict=(NSDictionary*)notification.object;
    
    HLog(@"%@",[dict objectForKey:@"title"]);
    
    [self.homeViewController searchForKeyword:dict];
}

-(void)onSearchHisKeyword:(NSNotification*)notification
{
    SearchHisEntity * entity=(SearchHisEntity*)notification.object;
    
    [self.homeViewController searchHisForKeyword:entity];
}

-(void)onSearchNearbyKeyword:(NSNotification*)notification
{
    NSDictionary* dict=(NSDictionary*)notification.object;
    
    HLog(@"%@",dict);
    [self.homeViewController searchNearbyForKeyword:dict];
}

-(void)onSearchTip:(NSNotification*)notification
{
    AMapPOI* poi=(AMapPOI*)notification.object;
    HLog(@"%@ %@",poi.citycode,poi.name);
//    [self.homeViewController searchForAMapTip:tip];
    [[DBManager getInstance] insertOrUpdateSearchHistory:[NSDictionary dictionaryWithObjectsAndKeys:poi.name,@"keyword",[NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]],@"insertTime",@"0",@"hisType",poi.adcode,@"adCode",poi.citycode,@"cityCode",[NSString stringWithFormat:@"%.6f",poi.location.latitude],@"latitude",[NSString stringWithFormat:@"%.6f",poi.location.longitude],@"longitude",poi.uid,@"dataId", nil]];
    
    [self.homeViewController searchForAMapPOI:poi];
}

-(void)onMapSelectDone:(NSNotification*)notification
{
    NSDictionary* dict=(NSDictionary*)notification.object;
    [self.homeViewController onMapSelectDone:dict];
}

-(void)reachabilityChanged:(NSNotification*)sender
{
    Reachability* reach=[sender object];
    if ([reach isReachable]) {
        [UserDefaultHelper setObject:reach.currentReachabilityString forKey:CONF_NETWORK_TYPE];
        HLog(@"%@",reach.currentReachabilityString);
    }else{
        HLog(@"----->%@",reach.currentReachabilityString);
        SIAlertView *alertView=[[SIAlertView alloc]initWithTitle:nil andMessage:@"网络连接失败,请检查网络设置."];
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
}

#ifdef __IPHONE_8_0
-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler
{
    if ([identifier isEqualToString:@"declineAction"]) {
        NSLog(@"declineAction ..");
    }else if([identifier isEqualToString:@"answerAction"]){
        NSLog(@"answerAction  ..");
    }
}
#endif

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //每次打开程序都会发送deviceToken,将device token转换为字符串
    NSString *deviceTokenStr = [NSString stringWithFormat:@"%@",deviceToken];
    deviceTokenStr = [deviceTokenStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
    deviceTokenStr = [deviceTokenStr stringByReplacingOccurrencesOfString:@">" withString:@""];
    deviceTokenStr = [deviceTokenStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *url = [NSString stringWithFormat:@"%@uuid",kHttpUrl];
    NSMutableDictionary* params=[NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:deviceTokenStr,@"uuid",@"0",@"status", nil]];
//    [self.networkEngine postOperationWithURLString:url params:params success:^(MKNetworkOperation *completedOperation, id result) {
//        
//    } error:^(NSError *error) {
//        DLog(@"post deviceToken fail");
//    }];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    HLog(@"%@",error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
//    NSString * type = [NSString stringWithFormat:@"%@",[userInfo objectForKey:PUSHTYPE]];//非字符串类型 转成NSString
//    if (application.applicationState != UIApplicationStateActive) {
//        if([type isEqualToString:PUSHTYPENEWS]) {//判断是否是 资讯 类型
//            NSDictionary *data = [userInfo objectForKey:@"data"];
//            NSString * newsId = [NSString stringWithFormat:@"%@",[data objectForKey:PUSHOBJECTID]];
//            NSString * title = [NSString stringWithFormat:@"%@",[data objectForKey:PUSHOBJECTIITLE]];
//            NSString * time = [NSString stringWithFormat:@"%@",[data objectForKey:PUSHOBJECTIIME]];
//            if(newsId.length>0 && title.length > 0)
//            {
//                //设置程序图标上的数字。当为0时 通知中心将会自动清空该程序的所有消息
//                //                [self pushNewsDetailWithNewsId:newsId withTitle:title withTime:time];
//            }
//        } else if ([type isEqualToString:PUSHTYPEPRIVNOTICE]) {
//            //私信
//            NSDictionary *data = [userInfo objectForKey:@"data"];
//            NSString * fromId = [NSString stringWithFormat:@"%@",[data objectForKey:PUSHPRIVNOTICEFROMID]];
//            NSString * nickname = [NSString stringWithFormat:@"%@",[data objectForKey:PUSHPRIVNOTICEFNICKNAME]];
//            if(fromId.length>0 && nickname.length > 0)
//            {
//                //设置程序图标上的数字。当为0时 通知中心将会自动清空该程序的所有消息
//                //                [self pushPrivChatViewWithUid:fromId withNickname:nickname];
//            }
//        }else if([type isEqualToString:PUSHTYPEDATAUPDATE]) {
//            //            [self updateData];
//        }
//    }else{
//        if ([type isEqualToString:PUSHTYPEDATAUPDATE]) {
//            //            [UIHelper showAlertViewWithMessage:@"有新的数据包，是否更新?" callback:^{
//            //                [self updateData];
//            //            }];
//        }
//    }
}



-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    
    return [UMSocialSnsService handleOpenURL:url];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [UMSocialSnsService handleOpenURL:url];
}

@end

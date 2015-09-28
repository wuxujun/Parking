//
//  AppDelegate.m
//  Parking
//
//  Created by xujunwu on 14-7-11.
//  Copyright (c) 2014年 ___Hongkui___. All rights reserved.
//

#import "AppDelegate.h"
#import "CustNavigationController.h"
#import "MenuViewController.h"
#import "UserDefaultHelper.h"
#import "HCurrentUserContext.h"
#import "DBHelper.h"
#import "DBManager.h"
#import "SearchHisEntity.h"

#import <AMapNaviKit/AMapNaviKit.h>
#import "iflyMSC/IFlySpeechSynthesizer.h"
#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySetting.h"
#import "iflyMSC/IFlyUserWords.h"

#import "MobClick.h"
#import <UMSocial.h>
#import <UMSocialSnsService.h>
#import <UMSocialWechatHandler.h>
#import <UMSocialQQHandler.h>
#import <UMSocialSinaHandler.h>

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
        NSLog(@"%@",result);
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
    
    [self initConfigData];
    
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSearchHisKeyword:) name:NOTIFICATION_SEARCH_HIS_KEYWORK object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSearchTip:) name:NOTIFICATION_SEARCH_TIP object:nil];
    

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
    
    return YES;
}

-(void)initConfigData
{
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
        [UserDefaultHelper setObject:[NSNumber numberWithBool:false] forKey:PRE_MAP_ZOOM];
    }

    if(![UserDefaultHelper objectForKey:PRE_NAVI_EMULATOR]){
        [UserDefaultHelper setObject:[NSNumber numberWithBool:false] forKey:PRE_NAVI_EMULATOR];
    }

    if(![UserDefaultHelper objectForKey:CONF_PARKING_STATUS]){
        [UserDefaultHelper setObject:[NSNumber numberWithBool:true] forKey:CONF_PARKING_STATUS];
    }
    
    if(![UserDefaultHelper objectForKey:CONF_PARKING_MOVE_SHOW]){
        [UserDefaultHelper setObject:[NSNumber numberWithBool:true] forKey:CONF_PARKING_MOVE_SHOW];
    }
    
    [UserDefaultHelper setObject:@"0" forKey:CONF_MAP_TO_LIST];
    [UserDefaultHelper setObject:@"0" forKey:CONF_LIST_TO_MAP];
    
    [UserDefaultHelper setObject:@"2" forKey:CONF_PARKING_MAP_CHARGE];
    [UserDefaultHelper setObject:@"0" forKey:CONF_PARKING_MAP_TYPE];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:CONF_DATABASE_VERSION];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [MobClick startWithAppkey:UMENG_APPKEY reportPolicy:BATCH channelId:@""];
    [MobClick setAppVersion:version];
    [UMSocialData setAppKey:UMENG_APPKEY];
    
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
    HCurrentUserContext* userContext=[HCurrentUserContext sharedInstance];
    if (userContext.uid) {
        [userContext loginWithUserName:[UserDefaultHelper objectForKey:PRE_LOGIN_USER] password:[UserDefaultHelper objectForKey:PRE_LOGIN_PASSWORD] success:^(MKNetworkOperation *completedOperation, id result) {
            HLog(@"%@",result);
        } error:^(NSError *error) {
            HLog(@"%@",error);
        }];
    }
    
}
							
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

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onOpenController:) name:NOTIFICATION_OPEN_TYPE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSearchKeyword:) name:NOTIFICATION_SEARCH_KEYWORK object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSearchTip:) name:NOTIFICATION_SEARCH_TIP object:nil];
    
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

-(void)onSearchTip:(NSNotification*)notification
{
    AMapPOI* poi=(AMapPOI*)notification.object;
    HLog(@"%@ %@",poi.citycode,poi.name);
//    [self.homeViewController searchForAMapTip:tip];
    [[DBManager getInstance] insertOrUpdateSearchHistory:[NSDictionary dictionaryWithObjectsAndKeys:poi.name,@"keyword",[NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]],@"insertTime",@"0",@"hisType",poi.adcode,@"adCode",poi.citycode,@"cityCode",[NSString stringWithFormat:@"%.6f",poi.location.latitude],@"latitude",[NSString stringWithFormat:@"%.6f",poi.location.longitude],@"longitude",poi.uid,@"dataId", nil]];
    
    [self.homeViewController searchForAMapPOI:poi];
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

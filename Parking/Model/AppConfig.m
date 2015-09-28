//
//  AppConfig.m
//  Electrical
//
//  Created by xujun wu on 13-7-7.
//  Copyright (c) 2013年 xujun wu. All rights reserved.
//

#import "AppConfig.h"
#import "StringUtil.h"

@implementation AppConfig
@synthesize isLogin;
@synthesize isNetworkRunning;

-(NSString*)getServiceName
{
    return @"http://wux63.bjsxp02.host.35.com";
}

-(NSString*)getDownPath
{
    NSString *downPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return downPath;
}

-(void)saveUserInfo:(NSString *)userName pwd:(NSString *)password
{
    NSUserDefaults *settings=[NSUserDefaults standardUserDefaults];
    [settings removeObjectForKey:@"userName"];
    [settings removeObjectForKey:@"password"];
    [settings setObject:userName forKey:@"userName"];
    
    [settings setObject:password forKey:@"password"];
    [settings synchronize];
}

-(NSString*)getUserName
{
    NSUserDefaults *settings=[NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"userName"];
}

-(NSString*)getPassword
{
    NSUserDefaults *settings=[NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"password"];
}

-(void)saveCompany:(NSDictionary*)info
{
    NSUserDefaults *settings=[NSUserDefaults standardUserDefaults];
    [settings removeObjectForKey:@"userCompany"];
    [settings setObject:info forKey:@"userCompany"];
    [settings synchronize];
}

-(NSDictionary*)getCompany
{
    NSUserDefaults *settings=[NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"userCompany"];
}


-(void)saveUserID:(int)uid
{
    NSUserDefaults *settings=[NSUserDefaults standardUserDefaults];
    [settings removeObjectForKey:@"UID"];
    [settings setObject:[NSString stringWithFormat:@"%d",uid] forKey:@"UID"];
    [settings synchronize];
}

-(int)getUID
{
    NSUserDefaults *settings=[NSUserDefaults standardUserDefaults];
    NSString   *value=[settings objectForKey:@"UID"];
    if (value&&[value isEqualToString:@""]==NO) {
        return [value intValue];
    }else{
        return 0;
    }
}

-(void)saveCookie:(BOOL)login
{
    NSUserDefaults *settings=[NSUserDefaults standardUserDefaults];
    [settings removeObjectForKey:@"cookie"];
    [settings setObject:login?@"1":@"0" forKey:@"cookie"];
    [settings synchronize];
}

-(BOOL)isCookie
{
    NSUserDefaults *settings=[NSUserDefaults standardUserDefaults];
    NSString *value=[settings objectForKey:@"cookie"];
    if (value&&[value isEqualToString:@"1"]) {
        return YES;
    }else{
        return NO;
    }
}

-(NSString*)getIMEI
{
    NSUserDefaults *settings=[NSUserDefaults standardUserDefaults];
    NSString   *value=[settings objectForKey:@"imei"];
    if (value&&[value isEqualToString:@""]==NO) {
        return value;
    }else{
        return @"1234";
    }
}

-(NSString*)getMapIcon:(int)dataType isSelect:(BOOL)sel fee:(NSString*)aFee count:(int)aCount
{
    NSString* img=@"ic_parking_blue";
    if (dataType==1) {
        if (aFee==(id)[NSNull null]||aFee.length==0) {
            img=@"ic_parking";
        }else if([aFee isEqualToString:@"1"]) {
            img=@"ic_parking_blue_fee";
            if (aCount<5) {
                img=@"ic_parking_red_fee";
            }else if(aCount>5&&aCount<15){
                img=@"ic_parking_org_fee";
            }else if(aCount>15){
                img=@"ic_parking_green_fee";
            }
        }else if([aFee isEqualToString:@"0"]){
            if (aCount<6) {
                img=@"ic_parking_red";
            }else if(aCount>5&&aCount<16){
                img=@"ic_parking_org";
            }else if(aCount>15){
                img=@"ic_parking_green";
            }

        }else{
            img=@"ic_parking";
        }
        if (sel) {
            img=@"ic_parking_blue_s2";
            if (aFee==(id)[NSNull null]||aFee.length==0) {
                img=@"ic_parking_s2";
            }else if ([aFee isEqualToString:@"1"]) {
                img=@"ic_parking_blue_fee_s2";
                if (aCount<5) {
                    img=@"ic_parking_red_fee_s2";
                }else if(aCount>5&&aCount<15){
                    img=@"ic_parking_org_fee_s2";
                }else if(aCount>15){
                    img=@"ic_parking_green_fee_s2";
                }
            }else if([aFee isEqualToString:@"0"]){
                if (aCount<5) {
                    img=@"ic_parking_red_s2";
                }else if(aCount>5&&aCount<15){
                    img=@"ic_parking_org_s2";
                }else if(aCount>15){
                    img=@"ic_parking_green_s2";
                }
            }else{
                img=@"ic_parking_s2";
            }
        }
    }else if (dataType==2) {
//        img=@"ic_bicycle_blue";
//        if (aCount<5) {
//            img=@"ic_bicycle_red";
//        }else if(aCount>5&&aCount<15){
            img=@"ic_bicycle_org";
//        }else if(aCount>15){
//            img=@"ic_bicycle_green";
//        }
        if (sel) {
//            img=@"ic_bicycle_blue_s2";
//            if (aCount<5) {
//                img=@"ic_bicycle_red_s2";
//            }else if(aCount>5&&aCount<15){
                img=@"ic_bicycle_org_s2";
//            }else if(aCount>15){
//                img=@"ic_bicycle_green_s2";
//            }
        }
    }else if(dataType==3){
        img=@"ic_bus_org";
        if (sel) {
            img=@"ic_bus_org_s2";
        }
    }
    return img;
}


static AppConfig *instance=nil;
+(AppConfig*)getInstance
{
    @synchronized(self){
        if (nil==instance) {
            [self new];
        }
    }
    return instance;
}

+(id)allocWithZone:(NSZone *)zone
{
    @synchronized(self){
        if (instance==nil) {
            instance=[super allocWithZone:zone];
            return instance;
        }
    }
    return nil;
}

@end

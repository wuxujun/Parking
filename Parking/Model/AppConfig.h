//
//  AppConfig.h
//  Electrical
//
//  Created by xujun wu on 13-7-7.
//  Copyright (c) 2013年 xujun wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppConfig : NSObject

@property BOOL  isLogin;

@property BOOL  isNetworkRunning;

-(NSString*)getServiceName;
-(NSString*)getDownPath;
-(NSString*)getPhotoFilePath;

-(void)saveUserInfo:(NSString*)userName pwd:(NSString*)password;
-(NSString*)getUserName;
-(NSString*)getPassword;

-(void)saveCompany:(NSDictionary*)info;
-(NSDictionary*)getCompany;

-(void)saveUserID:(int)uid;
-(int)getUID;

-(void)saveCookie:(BOOL)login;
-(BOOL)isCookie;

-(NSString*)getIMEI;
-(NSString*)getTMapIcon:(NSInteger)idx isSelect:(BOOL)sel;
-(NSString*)getMapIcon:(int)dataType isSelect:(BOOL)sel fee:(NSString*)aFee count:(int)aCount;
-(NSString*)getMapIcon:(int)dataType isSelect:(BOOL)sel fee:(NSString*)aFee status:(NSString*)aStatus;


+(AppConfig*)getInstance;
+(id)allocWithZone:(NSZone *)zone;

@end

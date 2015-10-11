//
//  ForgetPassController.m
//  Parking
//
//  Created by xujunwu on 15/9/16.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "ForgetPassController.h"
#import "UIViewController+NavigationBarButton.h"
#import "RegisterViewController.h"
#import "UIButton+Bootstrap.h"
#import "UserDefaultHelper.h"


#import "HNetworkEngine.h"
#import "UIView+LoadingView.h"
#import "HCurrentUserContext.h"

@interface ForgetPassController()<UITextFieldDelegate>

@property(nonatomic,strong)UITextField*  userField;
@property(nonatomic,strong)UITextField*  smsField;
@property(nonatomic,strong)UITextField*  passOldField;
@property(nonatomic,strong)UITextField*  passField;
@property(nonatomic,strong)UITextField*  passwField;
@property(nonatomic,strong)UIButton*     loginButton;
@property(nonatomic,strong)UIButton*     smsButton;


@property(nonatomic,strong)UIView*              userInputBG;
@property(nonatomic,strong)UIView*              smsInputBG;
@property(nonatomic,strong)UIView*              passOldInputBG;
@property(nonatomic,strong)UIView*              passInputBG;
@property(nonatomic,strong)UIView*              passwInputBG;

@property(nonatomic,strong)UILabel*             userLabel;
@property(nonatomic,strong)UILabel*             smsLabel;
@property(nonatomic,strong)UILabel*             passOldLabel;
@property(nonatomic,strong)UILabel*             passLabel;
@property(nonatomic,strong)UILabel*             passwLabel;

@end

@implementation ForgetPassController

-(void)viewDidLoad
{
    [super viewDidLoad];
    if (self.dataType==1) {
        [self setCenterTitle:@"修改密码"];
    }else{
        [self setCenterTitle:@"忘记密码"];
    }
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStylePlain target:self action:@selector(onClear:)];
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
}

-(IBAction)onClear:(id)sender
{
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.userField!=nil) {
        [self.userField becomeFirstResponder];
    }
}

-(IBAction)loginRequest:(id)sender
{
    [self passRequest];
}

-(void)passRequest
{
    NSString *usernameStr = [self.userField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *smsCode = [self.smsField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *oldPass=@"";
    if (self.dataType==1) {
        oldPass = [self.passOldField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    NSString *newPassStr = [self.passField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *passwordStr = [self.passwField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *errorMeg;
    
    if (usernameStr.length == 0) {
        errorMeg = @"请输入手机号。";
    }else if (smsCode.length == 0) {
        errorMeg = @"请输入验证码。";
    }
    if (self.dataType==1) {
        if (oldPass.length == 0) {
            errorMeg = @"请输入原密码。";
        }
    }
    if (newPassStr.length == 0) {
        errorMeg = @"请输入新密码。";
    }else if (passwordStr.length == 0) {
        errorMeg = @"请输入再次输入新密码。";
    }
    if (errorMeg) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:errorMeg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    } else {
        NSString* requestUrl=[NSString stringWithFormat:@"%@change_pwd",kHttpUrl];
        if (self.dataType==0) {
            requestUrl=[NSString stringWithFormat:@"%@reset_passwd",kHttpUrl];
        }
        NSMutableDictionary* params=[[NSMutableDictionary alloc]init];
        if (self.dataType==1) {
            [params setObject:oldPass forKey:@"passwd"];
        }else{
            [params setObject:@"1" forKey:@"modeType"];
            [params setObject:usernameStr forKey:@"verifyNumber"];
            [params setObject:@"0" forKey:@"verifyType"];
            [params setObject:@"0" forKey:@"authorizeCode"];
        }
        [params setObject:passwordStr forKey:@"newpwd"];
        [params setObject:smsCode forKey:@"captchaValue"];
        [params setObject:[UserDefaultHelper objectForKey:APP_REQUEST_CAPTCHA_ID] forKey:@"captchaId"];
        
        [self.view showHUDLoadingView:YES];
        [self.networkEngine postOperationWithURLString:requestUrl params:params success:^(MKNetworkOperation *completedOperation, id result) {
            if([[result objectForKey:@"status"] intValue]==200){
                [UserDefaultHelper setObject:passwordStr forKey:PRE_LOGIN_PASSWORD];
                if (self.dataType==1) {
                    [self alertRequestResult:@"修改成功" isPop:YES];
                    
                }else{
                    [self alertRequestResult:@"密码重置成功" isPop:YES];
                }
            }else{
                if (self.dataType==1) {
                    [self alertRequestResult:@"修改失败"];
                }else{
                    [self alertRequestResult:@"密码重置失败"];
                }
            }
            [self.view showHUDLoadingView:NO];
        } error:^(NSError *error) {
            HLog(@"%@",error);
            [self.view showHUDLoadingView:NO];
            [self alertRequestResult:@"网络请求失败"];
        }];
        
    }
}

-(IBAction)smsRequest:(id)sender
{
    
    NSString *usernameStr = [self.userField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *errorMeg;
    if (usernameStr.length == 0) {
        errorMeg = @"请输入手机号。";
    }
    if (errorMeg) {
        [self alertRequestResult:errorMeg];
    }else{
        [self.smsButton setEnabled:NO];
        [self timeout];
        NSString*   requestUrl=[NSString stringWithFormat:@"%@get_captcha",kHttpUrl];
        
        NSMutableDictionary* params=[NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"0",@"captchaType",@"2",@"returnType",@"1",@"sendSMS",usernameStr,@"sendNumber", nil]];
        if (self.dataType==0) {
            requestUrl=[NSString stringWithFormat:@"%@reset_passwd",kHttpUrl];
            params=[NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"0",@"modeType",@"0",@"verifyType",usernameStr,@"verifyNumber", nil]];
        }
        [self.networkEngine postOperationWithURLString:requestUrl params:params success:^(MKNetworkOperation *completedOperation, id result) {
            HLog(@"%@",result);
            [[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:APP_REQUEST_CAPTCHA_ID] forKey:APP_REQUEST_CAPTCHA_ID];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        } error:^(NSError *error) {
            NSLog(@"post deviceToken fail");
        }];
    }
}

-(void)timeout
{
    __block int timeout=60;
    dispatch_queue_t queue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        if (timeout<=0) {
            dispatch_source_cancel(timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.smsButton setEnabled:YES];
                [self.smsButton setTitle:@"点击获取" forState:UIControlStateNormal];
            });
        }else{
            int minutes=timeout/60;
            int seconds=timeout%60;
            NSString* strTime=[NSString stringWithFormat:@"%.2d秒",seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.smsButton setTitle:strTime forState:UIControlStateNormal];
            });
            timeout--;
        }
    });
    dispatch_resume(timer);
}



#define SMS_FIELD   400
#define USER_FIELD   100
#define OLD_PASSWORD_FIELD 101
#define PASSWORD_FIELD  200
#define PASSWORD_FIELD_2 300

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.dataType==1){
        return 6;
    }
    return 5;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    CGRect bounds=self.view.frame;
    switch (indexPath.row) {
        case 0:
        {
            self.userInputBG=[[UIView alloc]initWithFrame:CGRectMake(19.5, (80-46)/2-0.5, bounds.size.width-39, 47)];
            self.userInputBG.layer.masksToBounds=YES;
            self.userInputBG.layer.cornerRadius=5;
            [cell addSubview: self.userInputBG];
            
            self.userField=[[UITextField alloc] initWithFrame:CGRectMake(20, (80-46)/2, bounds.size.width-40, 46)];
            [self.userField setTextColor:DEFAULT_FONT_COLOR];
            [self.userField setAutocorrectionType:UITextAutocorrectionTypeNo];
            [self.userField setTag:USER_FIELD];
            [self.userField setPlaceholder:@"请输入手机号"];
            [self.userField setBorderStyle:UITextBorderStyleNone];
            [self.userField setFont:[UIFont systemFontOfSize:16.0f]];
            [self.userField setReturnKeyType:UIReturnKeyNext];
            [self.userField setClearButtonMode:UITextFieldViewModeWhileEditing];
            [self.userField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [self.userField setValue:DEFAULT_LINE_COLOR forKeyPath:@"_placeholderLabel.textColor"];
            if (IOS_VERSION_7_OR_ABOVE) {
                [self.userField setTintColor:DEFAULT_FONT_COLOR];
            }
            [self.userField.layer setMasksToBounds:YES];
            [self.userField.layer setCornerRadius:5.0f];
            [self.userField.layer setBorderColor:[DEFAULT_LINE_COLOR CGColor]];
            [self.userField.layer setBorderWidth:1.0];
            
            //            [self.userField setText:@"13958197001"];
            
            UIView *leftView=[[UIView alloc]init];
            CGRect frame=self.userField.frame;
            frame.size.width=86;
            [leftView setFrame:frame];
            self.userLabel=[[UILabel alloc]initWithFrame:CGRectMake(5, 10, 80, 26)];
            [self.userLabel setText:@"手机号"];
            [self.userLabel setTextAlignment:NSTextAlignmentCenter];
            [self.userLabel setTextColor:DEFAULT_FONT_COLOR];
            [leftView addSubview:self.userLabel];
            
            self.userField.leftViewMode=UITextFieldViewModeAlways;
            self.userField.leftView=leftView;
            [self.userField setDelegate:self];
            [cell addSubview:self.userField];
            
            break;
        }
        case 1:
        {
            self.smsInputBG=[[UIView alloc]initWithFrame:CGRectMake(19.5, (80-46)/2-0.5, bounds.size.width-39, 47)];
            self.smsInputBG.layer.masksToBounds=YES;
            self.smsInputBG.layer.cornerRadius=5;
            [cell addSubview: self.smsInputBG];
            
            self.smsField=[[UITextField alloc] initWithFrame:CGRectMake(20, (80-46)/2, bounds.size.width-40, 46)];
            [self.smsField setTextColor:DEFAULT_FONT_COLOR];
            [self.smsField setAutocorrectionType:UITextAutocorrectionTypeNo];
            [self.smsField setTag:SMS_FIELD];
            [self.smsField setPlaceholder:@"请输入验证码"];
            [self.smsField setBorderStyle:UITextBorderStyleNone];
            [self.smsField setFont:[UIFont systemFontOfSize:16.0f]];
            [self.smsField setReturnKeyType:UIReturnKeyGo];
            [self.smsField setKeyboardType:UIKeyboardTypeDecimalPad];
            [self.smsField setClearButtonMode:UITextFieldViewModeWhileEditing];
            [self.smsField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [self.smsField setValue:DEFAULT_LINE_COLOR forKeyPath:@"_placeholderLabel.textColor"];
            if (IOS_VERSION_7_OR_ABOVE) {
                [self.smsField setTintColor:DEFAULT_FONT_COLOR];
            }
            [self.smsField.layer setMasksToBounds:YES];
            [self.smsField.layer setCornerRadius:5.0f];
            [self.smsField.layer setBorderColor:[DEFAULT_LINE_COLOR CGColor]];
            [self.smsField.layer setBorderWidth:1.0];
            //            [self.userField setText:@"13958197001"];
            
            UIView *leftView=[[UIView alloc]init];
            CGRect frame=self.smsField.frame;
            frame.size.width=86;
            [leftView setFrame:frame];
            self.smsLabel=[[UILabel alloc]initWithFrame:CGRectMake(5, 10, 80, 26)];
            [self.smsLabel setText:@"验证码"];
            [self.smsLabel setTextAlignment:NSTextAlignmentCenter];
            [self.smsLabel setTextColor:DEFAULT_FONT_COLOR];
            [leftView addSubview:self.smsLabel];
            
            self.smsField.leftViewMode=UITextFieldViewModeAlways;
            self.smsField.leftView=leftView;
            
            self.smsButton=[[UIButton alloc] initWithFrame:CGRectMake(0, 10, 80, 44)];
            [self.smsButton setTitle:@"点击获取" forState:UIControlStateNormal];
            [self.smsButton.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
            [self.smsButton blueStyle];
            [self.smsButton addTarget:self action:@selector(smsRequest:) forControlEvents:UIControlEventTouchUpInside];
            
            self.smsField.rightViewMode=UITextFieldViewModeAlways;
            self.smsField.rightView=self.smsButton;
            
            [self.smsField setDelegate:self];
            [cell addSubview:self.smsField];
            
        }
            break;
        case 2:
        {
            if (self.dataType==1) {
                [self createOldPasswordCell:cell];
            }else{
                [self createPasswordCell:cell];
            }
            break;
        }
        case 3:
        {
            if (self.dataType==1) {
                [self createPasswordCell:cell];
            }else{
                [self createPassCell:cell];
            }
            
            break;
        }
        case 4:
        {
            if (self.dataType==1) {
                [self createPassCell:cell];
            }else{
                self.loginButton=[UIButton buttonWithType:UIButtonTypeCustom];
                [self.loginButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
                [self.loginButton setFrame:CGRectMake(20, (80-48)/2, bounds.size.width-40, 48)];
                [self.loginButton setTitle:@"重置密码" forState:UIControlStateNormal];
                [self.loginButton setTitleColor:DEFAULT_FONT_COLOR forState:UIControlStateNormal];
                [self.loginButton addTarget:self action:@selector(loginRequest:) forControlEvents:UIControlEventTouchUpInside];
                [self.loginButton blueStyle];
                [cell addSubview:self.loginButton];
            }
            break;
        }

        case 5:
        {
            self.loginButton=[UIButton buttonWithType:UIButtonTypeCustom];
            [self.loginButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
            [self.loginButton setFrame:CGRectMake(20, (80-48)/2, bounds.size.width-40, 48)];
            [self.loginButton setTitle:@"确认修改" forState:UIControlStateNormal];
            [self.loginButton setTitleColor:DEFAULT_FONT_COLOR forState:UIControlStateNormal];
            [self.loginButton addTarget:self action:@selector(loginRequest:) forControlEvents:UIControlEventTouchUpInside];
            [self.loginButton blueStyle];
            [cell addSubview:self.loginButton];
            
        }
            break;
        default:
            break;
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)createOldPasswordCell:(UITableViewCell*)cell
{
    CGRect bounds=self.view.frame;
    self.passOldInputBG=[[UIView alloc]initWithFrame:CGRectMake(19.5, (80-46)/2-0.5, bounds.size.width-39, 47)];
    self.passOldInputBG.layer.masksToBounds=YES;
    self.passOldInputBG.layer.cornerRadius=5;
    [cell addSubview:self.passOldInputBG];
    self.passOldField=[[UITextField alloc] initWithFrame:CGRectMake(20, (80-46)/2, bounds.size.width-40, 46)];
    [self.passOldField setTextColor:DEFAULT_FONT_COLOR];
    [self.passOldField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.passOldField setTag:OLD_PASSWORD_FIELD];
    [self.passOldField setPlaceholder:@"请输入原密码"];
    [self.passOldField setBorderStyle:UITextBorderStyleNone];
    [self.passOldField setFont:[UIFont systemFontOfSize:16.0f]];
    [self.passOldField setSecureTextEntry:YES];
    [self.passOldField setReturnKeyType:UIReturnKeyGo];
    [self.passOldField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.passOldField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.passOldField setValue:DEFAULT_LINE_COLOR forKeyPath:@"_placeholderLabel.textColor"];
    [self.passOldField.layer setMasksToBounds:YES];
    [self.passOldField.layer setCornerRadius:5.0f];
    [self.passOldField.layer setBorderColor:[DEFAULT_LINE_COLOR CGColor]];
    [self.passOldField.layer setBorderWidth:1.0];
    if (IOS_VERSION_7_OR_ABOVE) {
        [self.passOldField setTintColor:DEFAULT_FONT_COLOR];
    }
    //            [self.passField setText:@"123456"];
    
    UIView *leftView=[[UIView alloc]init];
    CGRect frame=self.passOldField.frame;
    frame.size.width=86;
    [leftView setFrame:frame];
    self.passOldLabel=[[UILabel alloc]initWithFrame:CGRectMake(5, 10, 80, 26)];
    [self.passOldLabel setText:@"原密码"];
    [self.passOldLabel setTextAlignment:NSTextAlignmentCenter];
    [self.passOldLabel setTextColor:DEFAULT_FONT_COLOR];
    [leftView addSubview:self.passOldLabel];
    
    self.passOldField.leftViewMode=UITextFieldViewModeAlways;
    self.passOldField.leftView=leftView;
    
    [self.passOldField setDelegate:self];
    [cell addSubview:self.passOldField];
}

-(void)createPasswordCell:(UITableViewCell*)cell
{
    CGRect bounds=self.view.frame;
    self.passInputBG=[[UIView alloc]initWithFrame:CGRectMake(19.5, (80-46)/2-0.5, bounds.size.width-39, 47)];
    self.passInputBG.layer.masksToBounds=YES;
    self.passInputBG.layer.cornerRadius=5;
    [cell addSubview:self.passInputBG];
    self.passField=[[UITextField alloc] initWithFrame:CGRectMake(20, (80-46)/2, bounds.size.width-40, 46)];
    [self.passField setTextColor:DEFAULT_FONT_COLOR];
    [self.passField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.passField setTag:PASSWORD_FIELD];
    [self.passField setPlaceholder:@"请输入新密码"];
    [self.passField setBorderStyle:UITextBorderStyleNone];
    [self.passField setFont:[UIFont systemFontOfSize:16.0f]];
    [self.passField setSecureTextEntry:YES];
    [self.passField setReturnKeyType:UIReturnKeyGo];
    [self.passField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.passField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.passField setValue:DEFAULT_LINE_COLOR forKeyPath:@"_placeholderLabel.textColor"];
    [self.passField.layer setMasksToBounds:YES];
    [self.passField.layer setCornerRadius:5.0f];
    [self.passField.layer setBorderColor:[DEFAULT_LINE_COLOR CGColor]];
    [self.passField.layer setBorderWidth:1.0];
    if (IOS_VERSION_7_OR_ABOVE) {
        [self.passField setTintColor:DEFAULT_FONT_COLOR];
    }
    //            [self.passField setText:@"123456"];
    
    UIView *leftView=[[UIView alloc]init];
    CGRect frame=self.passField.frame;
    frame.size.width=86;
    [leftView setFrame:frame];
    self.passLabel=[[UILabel alloc]initWithFrame:CGRectMake(5, 10, 80, 26)];
    [self.passLabel setText:@"新密码"];
    [self.passLabel setTextAlignment:NSTextAlignmentCenter];
    [self.passLabel setTextColor:DEFAULT_FONT_COLOR];
    [leftView addSubview:self.passLabel];
    
    self.passField.leftViewMode=UITextFieldViewModeAlways;
    self.passField.leftView=leftView;
    
    [self.passField setDelegate:self];
    [cell addSubview:self.passField];
}

-(void)createPassCell:(UITableViewCell*)cell
{
    CGRect bounds=self.view.frame;
    
    self.passwInputBG=[[UIView alloc]initWithFrame:CGRectMake(19.5, (80-46)/2-0.5, bounds.size.width-39, 47)];
    self.passwInputBG.layer.masksToBounds=YES;
    self.passwInputBG.layer.cornerRadius=5;
    [cell addSubview:self.passwInputBG];
    self.passwField=[[UITextField alloc] initWithFrame:CGRectMake(20, (80-46)/2, bounds.size.width-40, 46)];
    [self.passwField setTextColor:DEFAULT_FONT_COLOR];
    [self.passwField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.passwField setTag:PASSWORD_FIELD_2];
    [self.passwField setPlaceholder:@"请再次输入新密码"];
    [self.passwField setBorderStyle:UITextBorderStyleNone];
    [self.passwField setFont:[UIFont systemFontOfSize:16.0f]];
    [self.passwField setSecureTextEntry:YES];
    [self.passwField setReturnKeyType:UIReturnKeyGo];
    [self.passwField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.passwField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.passwField setValue:DEFAULT_LINE_COLOR forKeyPath:@"_placeholderLabel.textColor"];
    [self.passwField.layer setMasksToBounds:YES];
    [self.passwField.layer setCornerRadius:5.0f];
    [self.passwField.layer setBorderColor:[DEFAULT_LINE_COLOR CGColor]];
    [self.passwField.layer setBorderWidth:1.0];
    if (IOS_VERSION_7_OR_ABOVE) {
        [self.passwField setTintColor:DEFAULT_FONT_COLOR];
    }
    //            [self.passField setText:@"123456"];
    
    UIView *leftView=[[UIView alloc]init];
    CGRect frame=self.passwField.frame;
    frame.size.width=86;
    [leftView setFrame:frame];
    self.passwLabel=[[UILabel alloc]initWithFrame:CGRectMake(5, 10, 80, 26)];
    [self.passwLabel setText:@"确认密码"];
    [self.passwLabel setTextAlignment:NSTextAlignmentCenter];
    [self.passwLabel setTextColor:DEFAULT_FONT_COLOR];
    [leftView addSubview:self.passwLabel];
    
    self.passwField.leftViewMode=UITextFieldViewModeAlways;
    self.passwField.leftView=leftView;
    
    [self.passwField setDelegate:self];
    [cell addSubview:self.passwField];
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    int tag=[textField tag];
    if (tag==USER_FIELD&&[textField returnKeyType]==UIReturnKeyNext) {
        if (self.smsField) {
            [self.smsField becomeFirstResponder];
        }
    }else if(tag==PASSWORD_FIELD_2&&[textField returnKeyType]==UIReturnKeyGo){
        [self passRequest];
    }
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}


@end

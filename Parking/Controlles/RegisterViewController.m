//
//  RegisterViewController.m
//  Parking
//
//  Created by xujunwu on 15/9/16.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "RegisterViewController.h"
#import "HNetworkEngine.h"
#import "UIViewController+NavigationBarButton.h"
#import "RegisterViewController.h"
#import "UIButton+Bootstrap.h"

#import "HNetworkEngine.h"
#import "UIView+LoadingView.h"
#import "HCurrentUserContext.h"

@interface RegisterViewController()<UITextFieldDelegate>

@property(nonatomic,strong)UITextField*  userField;
@property(nonatomic,strong)UITextField*  passField;
@property(nonatomic,strong)UITextField*  smsField;
@property(nonatomic,strong)UIButton*     loginButton;
@property(nonatomic,strong)UIButton*     smsButton;


@property(nonatomic,strong)UIView*              userInputBG;
@property(nonatomic,strong)UIView*              passInputBG;
@property(nonatomic,strong)UIView*              smsInputBG;

@property(nonatomic,strong)UILabel*             userLabel;
@property(nonatomic,strong)UILabel*             passLabel;
@property(nonatomic,strong)UILabel*             smsLabel;


@end

@implementation RegisterViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setCenterTitle:@"用户注册"];
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

-(IBAction)onRegister:(id)sender
{
    
}

-(IBAction)loginRequest:(id)sender
{
    [self login];
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


-(void)login
{
    NSString *usernameStr = [self.userField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *passwordStr = [self.passField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* smsStr=[self.smsField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *errorMsg;
    if (usernameStr.length == 0) {
        errorMsg = @"请输入用户帐号。";
    } else if (passwordStr.length == 0) {
        errorMsg = @"请输入用户密码。";
    }else if(smsStr.length==0){
        errorMsg=@"请输入验证码";
    }
    if (errorMsg) {
        [self alertRequestResult:errorMsg];
    } else {
        HCurrentUserContext *userContext = [HCurrentUserContext sharedInstance];
        __weak RegisterViewController *myself = self;
        [self.view showHUDLoadingView:YES];
        [userContext registerWithUserName:usernameStr password:passwordStr sms:smsStr success:^(BOOL success) {
            if (success) {
                [[NSUserDefaults standardUserDefaults]setObject:usernameStr forKey:PRE_LOGIN_USER];
                [[NSUserDefaults standardUserDefaults] setObject:passwordStr forKey:PRE_LOGIN_PASSWORD];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [myself.navigationController popViewControllerAnimated:YES];
            }else{
                NSLog(@"注册失败");
            }
            
        } error:^(NSError *error) {
            [myself.view showHUDLoadingView:NO];
        }];
    }
}

#define USER_FIELD   100
#define PASSWORD_FIELD  200

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
    
    return 4;
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
            [self.userField setPlaceholder:@"请输入手机号码"];
            [self.userField setBorderStyle:UITextBorderStyleNone];
            [self.userField setFont:[UIFont systemFontOfSize:16.0f]];
            [self.userField setReturnKeyType:UIReturnKeyNext];
            [self.userField setKeyboardType:UIKeyboardTypePhonePad];
            [self.userField setClearButtonMode:UITextFieldViewModeWhileEditing];
            [self.userField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [self.userField setValue:DEFAULT_FONT_COLOR forKeyPath:@"_placeholderLabel.textColor"];
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
            frame.size.width=66;
            [leftView setFrame:frame];
            self.userLabel=[[UILabel alloc]initWithFrame:CGRectMake(5, 10, 66, 26)];
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
            self.passInputBG=[[UIView alloc]initWithFrame:CGRectMake(19.5, (80-46)/2-0.5, bounds.size.width-39, 47)];
            self.passInputBG.layer.masksToBounds=YES;
            self.passInputBG.layer.cornerRadius=5;
            [cell addSubview:self.passInputBG];
            self.passField=[[UITextField alloc] initWithFrame:CGRectMake(20, (80-46)/2, bounds.size.width-40, 46)];
            [self.passField setTextColor:DEFAULT_FONT_COLOR];
            [self.passField setAutocorrectionType:UITextAutocorrectionTypeNo];
            [self.passField setTag:PASSWORD_FIELD];
            [self.passField setPlaceholder:@"请输入密码"];
            [self.passField setBorderStyle:UITextBorderStyleNone];
            [self.passField setFont:[UIFont systemFontOfSize:16.0f]];
            [self.passField setSecureTextEntry:YES];
            [self.passField setReturnKeyType:UIReturnKeyNext];
            [self.passField setClearButtonMode:UITextFieldViewModeWhileEditing];
            [self.passField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [self.passField setValue:DEFAULT_FONT_COLOR forKeyPath:@"_placeholderLabel.textColor"];
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
            frame.size.width=66;
            [leftView setFrame:frame];
            self.passLabel=[[UILabel alloc]initWithFrame:CGRectMake(5, 10, 66, 26)];
            [self.passLabel setText:@"密码"];
            [self.passLabel setTextAlignment:NSTextAlignmentCenter];
            [self.passLabel setTextColor:DEFAULT_FONT_COLOR];
            [leftView addSubview:self.passLabel];
            
            self.passField.leftViewMode=UITextFieldViewModeAlways;
            self.passField.leftView=leftView;
            
            [self.passField setDelegate:self];
            [cell addSubview:self.passField];
            break;
        }
        case 3:
        {
            self.loginButton=[UIButton buttonWithType:UIButtonTypeCustom];
            [self.loginButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
            [self.loginButton setFrame:CGRectMake(20, (80-48)/2, bounds.size.width-40, 48)];
            [self.loginButton setTitle:@"注册" forState:UIControlStateNormal];
            [self.loginButton setTitleColor:DEFAULT_FONT_COLOR forState:UIControlStateNormal];
            [self.loginButton addTarget:self action:@selector(loginRequest:) forControlEvents:UIControlEventTouchUpInside];
            [self.loginButton blueStyle];
            [cell addSubview:self.loginButton];
            
        }
            break;
        case 2:
        {
            self.smsInputBG=[[UIView alloc]initWithFrame:CGRectMake(19.5, (80-46)/2-0.5, bounds.size.width-39, 47)];
            self.smsInputBG.layer.masksToBounds=YES;
            self.smsInputBG.layer.cornerRadius=5;
            [cell addSubview: self.smsInputBG];
            
            self.smsField=[[UITextField alloc] initWithFrame:CGRectMake(20, (80-46)/2, bounds.size.width-40, 46)];
            [self.smsField setTextColor:DEFAULT_FONT_COLOR];
            [self.smsField setAutocorrectionType:UITextAutocorrectionTypeNo];
            [self.smsField setTag:USER_FIELD];
            [self.smsField setPlaceholder:@"请输入验证码"];
            [self.smsField setBorderStyle:UITextBorderStyleNone];
            [self.smsField setFont:[UIFont systemFontOfSize:16.0f]];
            [self.smsField setReturnKeyType:UIReturnKeyGo];
            [self.smsField setKeyboardType:UIKeyboardTypeDecimalPad];
            [self.smsField setClearButtonMode:UITextFieldViewModeWhileEditing];
            [self.smsField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [self.smsField setValue:DEFAULT_FONT_COLOR forKeyPath:@"_placeholderLabel.textColor"];
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
            frame.size.width=66;
            [leftView setFrame:frame];
            self.smsLabel=[[UILabel alloc]initWithFrame:CGRectMake(5, 10, 66, 26)];
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
        default:
            break;
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    int tag=[textField tag];
    if (tag==USER_FIELD&&[textField returnKeyType]==UIReturnKeyNext) {
        if (self.passField) {
            [self.passField becomeFirstResponder];
        }
    }else if(tag==PASSWORD_FIELD&&[textField returnKeyType]==UIReturnKeyGo){
        [self login];
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

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

#import "HNetworkEngine.h"
#import "UIView+LoadingView.h"
#import "HCurrentUserContext.h"

@interface ForgetPassController()<UITextFieldDelegate>

@property(nonatomic,strong)UITextField*  userField;
@property(nonatomic,strong)UITextField*  passField;
@property(nonatomic,strong)UIButton*     loginButton;
@property(nonatomic,strong)UIButton*     forgetButton;


@property(nonatomic,strong)UIView*              userInputBG;
@property(nonatomic,strong)UIView*              passInputBG;

@property(nonatomic,strong)UILabel*             userLabel;
@property(nonatomic,strong)UILabel*             passLabel;


@end

@implementation ForgetPassController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setCenterTitle:@"找回密码"];
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
    [self login];
}

-(void)login
{
    NSString *usernameStr = [self.userField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *passwordStr = [self.passField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *errorMeg;
    if (usernameStr.length == 0) {
        errorMeg = @"请输入用户帐号。";
    } else if (passwordStr.length == 0) {
        errorMeg = @"请输入用户密码。";
    }
    if (errorMeg) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:errorMeg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    } else {
        HCurrentUserContext *userContext = [HCurrentUserContext sharedInstance];
        __weak ForgetPassController *myself = self;
        [self.view showHUDLoadingView:YES];
        [userContext loginWithUserName:usernameStr password:passwordStr success:^(MKNetworkOperation *completedOperation, id result) {
            DLog(@"%@",result);
            [myself.navigationController popViewControllerAnimated:YES];
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
    return 3;
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
            [self.userField setPlaceholder:@"请输入登录帐号"];
            [self.userField setBorderStyle:UITextBorderStyleNone];
            [self.userField setFont:[UIFont systemFontOfSize:16.0f]];
            [self.userField setReturnKeyType:UIReturnKeyNext];
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
            frame.size.width=60;
            [leftView setFrame:frame];
            self.userLabel=[[UILabel alloc]initWithFrame:CGRectMake(5, 10, 60, 26)];
            [self.userLabel setText:@"帐号"];
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
            [self.passField setReturnKeyType:UIReturnKeyGo];
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
            frame.size.width=60;
            [leftView setFrame:frame];
            self.passLabel=[[UILabel alloc]initWithFrame:CGRectMake(5, 10, 60, 26)];
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
        case 2:
        {
            self.loginButton=[UIButton buttonWithType:UIButtonTypeCustom];
            [self.loginButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
            [self.loginButton setFrame:CGRectMake(20, (80-48)/2, bounds.size.width-40, 48)];
            [self.loginButton setTitle:@"登录" forState:UIControlStateNormal];
            [self.loginButton setTitleColor:DEFAULT_FONT_COLOR forState:UIControlStateNormal];
            [self.loginButton addTarget:self action:@selector(loginRequest:) forControlEvents:UIControlEventTouchUpInside];
            [self.loginButton blueStyle];
            [cell addSubview:self.loginButton];
            
        }
            break;
        case 3:
        {
            self.forgetButton=[UIButton buttonWithType:UIButtonTypeCustom];
            [self.forgetButton.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
            [self.forgetButton setFrame:CGRectMake(bounds.size.width-120, 5, 100, 40)];
            [self.forgetButton setTitle:@"忘记密码" forState:UIControlStateNormal];
            [self.forgetButton setTitleColor:DEFAULT_FONT_COLOR forState:UIControlStateNormal];
            [self.forgetButton setTitleColor:DEFAULT_FONT_COLOR forState:UIControlStateHighlighted];
            [self.forgetButton setBackgroundColor:[UIColor clearColor]];
            [self.forgetButton addTarget:self action:@selector(passRequest:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell addSubview:self.forgetButton];
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

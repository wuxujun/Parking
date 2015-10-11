//
//  DoomViewController.m
//  Parking
//
//  Created by xujunwu on 15/10/2.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import "DoomViewController.h"
#import "UIViewController+NavigationBarButton.h"
#import "RegisterViewController.h"
#import "ForgetPassController.h"
#import "UIButton+Bootstrap.h"
#import "UserDefaultHelper.h"

#import "HNetworkEngine.h"
#import "UIView+LoadingView.h"
#import "HCurrentUserContext.h"

@interface DoomViewController ()<UITextFieldDelegate>

@property(nonatomic,strong)UITextField*  carField;
@property(nonatomic,strong)UITextField  *    typeField;
@property(nonatomic,strong)UITextField  *    beginTimeField;
@property(nonatomic,strong)UITextField  *    endTimeField;

@property(nonatomic,strong)UIButton*     submitButton;


@property(nonatomic,strong)UIView*              carInputBG;
@property(nonatomic,strong)UIView*              typeInputBG;
@property(nonatomic,strong)UIView*              beginInputBG;
@property(nonatomic,strong)UIView*              endInputBG;

@property(nonatomic,strong)UILabel*             carLabel;
@property(nonatomic,strong)UILabel*             typeLabel;
@property(nonatomic,strong)UILabel*             beginLabel;
@property(nonatomic,strong)UILabel*             endLable;

@end

@implementation DoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setCenterTitle:@"预定车位"];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStylePlain target:self action:@selector(onClear:)];
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
}

-(IBAction)onClear:(id)sender
{
    
}

-(IBAction)submitRequest:(id)sender
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
            self.carInputBG=[[UIView alloc]initWithFrame:CGRectMake(19.5, (80-46)/2-0.5, bounds.size.width-39, 47)];
            self.carInputBG.layer.masksToBounds=YES;
            self.carInputBG.layer.cornerRadius=5;
            [cell addSubview: self.carInputBG];
            
            self.carField=[[UITextField alloc] initWithFrame:CGRectMake(20, (80-46)/2, bounds.size.width-40, 46)];
            [self.carField setTextColor:DEFAULT_FONT_COLOR];
            [self.carField setAutocorrectionType:UITextAutocorrectionTypeNo];
            [self.carField setPlaceholder:@"请输入车辆号牌"];
            [self.carField setBorderStyle:UITextBorderStyleNone];
            [self.carField setFont:[UIFont systemFontOfSize:16.0f]];
            [self.carField setReturnKeyType:UIReturnKeyNext];
            [self.carField setClearButtonMode:UITextFieldViewModeWhileEditing];
            [self.carField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [self.carField setValue:DEFAULT_LINE_COLOR forKeyPath:@"_placeholderLabel.textColor"];
            if (IOS_VERSION_7_OR_ABOVE) {
                [self.carField setTintColor:DEFAULT_FONT_COLOR];
            }
            [self.carField.layer setMasksToBounds:YES];
            [self.carField.layer setCornerRadius:5.0f];
            [self.carField.layer setBorderWidth:1.0];
            [self.carField.layer setBorderColor:[DEFAULT_LINE_COLOR CGColor]];
            
            UIView *leftView=[[UIView alloc]init];
            CGRect frame=self.carField.frame;
            frame.size.width=86;
            [leftView setFrame:frame];
            self.carLabel=[[UILabel alloc]initWithFrame:CGRectMake(5, 10, 80, 26)];
            [self.carLabel setText:@"车辆号牌"];
            [self.carLabel setTextAlignment:NSTextAlignmentCenter];
            [self.carLabel setTextColor:DEFAULT_FONT_COLOR];
            [leftView addSubview:self.carLabel];
            
            self.carField.leftViewMode=UITextFieldViewModeAlways;
            self.carField.leftView=leftView;
            [self.carField setDelegate:self];
            [cell addSubview:self.carField];
            
            break;
        }
        case 1:
        {
            self.typeInputBG=[[UIView alloc]initWithFrame:CGRectMake(19.5, (80-46)/2-0.5, bounds.size.width-39, 47)];
            self.typeInputBG.layer.masksToBounds=YES;
            self.typeInputBG.layer.cornerRadius=5;
            [cell addSubview:self.typeInputBG];
            self.typeField=[[UITextField alloc] initWithFrame:CGRectMake(20, (80-46)/2, bounds.size.width-40, 46)];
            [self.typeField setTextColor:DEFAULT_FONT_COLOR];
            [self.typeField setAutocorrectionType:UITextAutocorrectionTypeNo];
            [self.typeField setPlaceholder:@"请选择停车场"];
            [self.typeField setBorderStyle:UITextBorderStyleNone];
            [self.typeField setFont:[UIFont systemFontOfSize:16.0f]];
            [self.typeField setSecureTextEntry:YES];
            [self.typeField setReturnKeyType:UIReturnKeyGo];
            [self.typeField setClearButtonMode:UITextFieldViewModeWhileEditing];
            [self.typeField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [self.typeField setValue:DEFAULT_LINE_COLOR forKeyPath:@"_placeholderLabel.textColor"];
            [self.typeField.layer setMasksToBounds:YES];
            [self.typeField.layer setCornerRadius:5.0f];
            [self.typeField.layer setBorderWidth:1.0];
            [self.typeField.layer setBorderColor:[DEFAULT_LINE_COLOR CGColor]];
            if (IOS_VERSION_7_OR_ABOVE) {
                [self.typeField setTintColor:DEFAULT_FONT_COLOR];
            }
            //            [self.passField setText:@"123456"];
            
            UIView *leftView=[[UIView alloc]init];
            CGRect frame=self.typeField.frame;
            frame.size.width=86;
            [leftView setFrame:frame];
            self.typeLabel=[[UILabel alloc]initWithFrame:CGRectMake(5, 10, 80, 26)];
            [self.typeLabel setText:@"停车场"];
            [self.typeLabel setTextAlignment:NSTextAlignmentCenter];
            [self.typeLabel setTextColor:DEFAULT_FONT_COLOR];
            [leftView addSubview:self.typeLabel];
            
            self.typeField.leftViewMode=UITextFieldViewModeAlways;
            self.typeField.leftView=leftView;
            
            [self.typeField setDelegate:self];
            [cell addSubview:self.typeField];
            break;
        }
        case 2:
        {
            self.beginInputBG=[[UIView alloc]initWithFrame:CGRectMake(19.5, (80-46)/2-0.5, bounds.size.width-39, 47)];
            self.beginInputBG.layer.masksToBounds=YES;
            self.beginInputBG.layer.cornerRadius=5;
            [cell addSubview:self.beginInputBG];
            self.beginTimeField=[[UITextField alloc] initWithFrame:CGRectMake(20, (80-46)/2, bounds.size.width-40, 46)];
            [self.beginTimeField setTextColor:DEFAULT_FONT_COLOR];
            [self.beginTimeField setAutocorrectionType:UITextAutocorrectionTypeNo];
            [self.beginTimeField setPlaceholder:@"请选择开始时间"];
            [self.beginTimeField setBorderStyle:UITextBorderStyleNone];
            [self.beginTimeField setFont:[UIFont systemFontOfSize:16.0f]];
            [self.beginTimeField setSecureTextEntry:YES];
            [self.beginTimeField setReturnKeyType:UIReturnKeyGo];
            [self.beginTimeField setClearButtonMode:UITextFieldViewModeWhileEditing];
            [self.beginTimeField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [self.beginTimeField setValue:DEFAULT_LINE_COLOR forKeyPath:@"_placeholderLabel.textColor"];
            [self.beginTimeField.layer setMasksToBounds:YES];
            [self.beginTimeField.layer setCornerRadius:5.0f];
            [self.beginTimeField.layer setBorderWidth:1.0];
            [self.beginTimeField.layer setBorderColor:[DEFAULT_LINE_COLOR CGColor]];
            if (IOS_VERSION_7_OR_ABOVE) {
                [self.beginTimeField setTintColor:DEFAULT_FONT_COLOR];
            }
            //            [self.passField setText:@"123456"];
            
            UIView *leftView=[[UIView alloc]init];
            CGRect frame=self.beginTimeField.frame;
            frame.size.width=86;
            [leftView setFrame:frame];
            self.beginLabel=[[UILabel alloc]initWithFrame:CGRectMake(5, 10, 80, 26)];
            [self.beginLabel setText:@"开始时间"];
            [self.beginLabel setTextAlignment:NSTextAlignmentCenter];
            [self.beginLabel setTextColor:DEFAULT_FONT_COLOR];
            [leftView addSubview:self.beginLabel];
            
            self.beginTimeField.leftViewMode=UITextFieldViewModeAlways;
            self.beginTimeField.leftView=leftView;
            
            [self.beginTimeField setDelegate:self];
            [cell addSubview:self.beginTimeField];
            break;
        }
        case 3:
        {
            self.endInputBG=[[UIView alloc]initWithFrame:CGRectMake(19.5, (80-46)/2-0.5, bounds.size.width-39, 47)];
            self.endInputBG.layer.masksToBounds=YES;
            self.endInputBG.layer.cornerRadius=5;
            [cell addSubview:self.endInputBG];
            self.endTimeField=[[UITextField alloc] initWithFrame:CGRectMake(20, (80-46)/2, bounds.size.width-40, 46)];
            [self.endTimeField setTextColor:DEFAULT_FONT_COLOR];
            [self.endTimeField setAutocorrectionType:UITextAutocorrectionTypeNo];
            [self.endTimeField setPlaceholder:@"请选择结束时间"];
            [self.endTimeField setBorderStyle:UITextBorderStyleNone];
            [self.endTimeField setFont:[UIFont systemFontOfSize:16.0f]];
            [self.endTimeField setSecureTextEntry:YES];
            [self.endTimeField setReturnKeyType:UIReturnKeyGo];
            [self.endTimeField setClearButtonMode:UITextFieldViewModeWhileEditing];
            [self.endTimeField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [self.endTimeField setValue:DEFAULT_LINE_COLOR forKeyPath:@"_placeholderLabel.textColor"];
            [self.endTimeField.layer setMasksToBounds:YES];
            [self.endTimeField.layer setCornerRadius:5.0f];
            [self.endTimeField.layer setBorderWidth:1.0];
            [self.endTimeField.layer setBorderColor:[DEFAULT_LINE_COLOR CGColor]];
            if (IOS_VERSION_7_OR_ABOVE) {
                [self.endTimeField setTintColor:DEFAULT_FONT_COLOR];
            }
            //            [self.passField setText:@"123456"];
            
            UIView *leftView=[[UIView alloc]init];
            CGRect frame=self.endTimeField.frame;
            frame.size.width=86;
            [leftView setFrame:frame];
            self.endLable=[[UILabel alloc]initWithFrame:CGRectMake(5, 10, 80, 26)];
            [self.endLable setText:@"结束时间"];
            [self.endLable setTextAlignment:NSTextAlignmentCenter];
            [self.endLable setTextColor:DEFAULT_FONT_COLOR];
            [leftView addSubview:self.endLable];
            
            self.endTimeField.leftViewMode=UITextFieldViewModeAlways;
            self.endTimeField.leftView=leftView;
            
            [self.endTimeField setDelegate:self];
            [cell addSubview:self.endTimeField];
            break;
        }
        case 4:
        {
            self.submitButton=[UIButton buttonWithType:UIButtonTypeCustom];
            [self.submitButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
            [self.submitButton setFrame:CGRectMake(20, (80-48)/2, bounds.size.width-40, 48)];
            [self.submitButton setTitle:@"确定预约" forState:UIControlStateNormal];
            [self.submitButton setTitleColor:DEFAULT_FONT_COLOR forState:UIControlStateNormal];
            [self.submitButton addTarget:self action:@selector(submitRequest:) forControlEvents:UIControlEventTouchUpInside];
            [self.submitButton blueStyle];
            [cell addSubview:self.submitButton];
            
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

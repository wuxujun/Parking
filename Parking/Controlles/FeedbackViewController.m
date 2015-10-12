//
//  FeedbackViewController.m
//  Parking
//
//  Created by xujunwu on 15/9/16.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "FeedbackViewController.h"
#import "UIViewController+NavigationBarButton.h"
#import "RegisterViewController.h"
#import "UIButton+Bootstrap.h"
#import "HNetworkEngine.h"
#import "UIView+LoadingView.h"
#import "HCurrentUserContext.h"
#import "SIAlertView.h"

@interface FeedbackViewController()<UITextFieldDelegate>

@property(nonatomic,strong)UITextField*  contentField;
@property(nonatomic,strong)UIButton*     submitButton;

@property(nonatomic,strong)UILabel*      tipLabel;
@property(nonatomic,strong)UILabel*      typeLabel;

@end

@implementation FeedbackViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setCenterTitle:@"反馈有奖"];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStylePlain target:self action:@selector(onClear:)];
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(IBAction)onClear:(id)sender
{
    self.contentField.text=@"";
}

-(IBAction)submitRequest:(id)sender
{
    [self submit];
}

-(void)submit
{
    NSInteger type=[self.typeLabel tag];
    NSString *contentStr = [self.contentField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *errorMeg;
    if (contentStr.length == 0) {
        errorMeg = @"请输入反馈内容。";
    }
    if (errorMeg) {
        [self alertRequestResult:errorMeg];
    } else {
        __weak FeedbackViewController *myself = self;
        [self.view showHUDLoadingView:YES];
        NSString* requestUrl=[NSString stringWithFormat:@"%@feedback",kHttpUrl];
        NSMutableDictionary* params=[[NSMutableDictionary alloc]init];
        [params setObject:[NSString stringWithFormat:@"%d",type] forKey:@"opinionType"];
        [params setObject:[NSString stringWithFormat:@"%@",contentStr] forKey:@"opinionContent"];
        
        [self.networkEngine postOperationWithURLString:requestUrl params:params success:^(MKNetworkOperation *completedOperation, id result) {
            HLog(@"%@",result);
            [self.view showHUDLoadingView:NO];
            if([[result objectForKey:@"status"] intValue]==200){
                [myself alertRequestResult:@"提交成功"];
            }else{
                [myself alertRequestResult:[result objectForKey:@"msg"]];
            }
        } error:^(NSError *error) {
            HLog(@"%@",error);
            [self.view showHUDLoadingView:NO];
        }];
    }
}

#define CONTENT_FIELD   100

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==1) {
        return 300;
    }
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
        case 0:{
            UILabel* lb=[[UILabel alloc]initWithFrame:CGRectMake(10, 10, 100, 44)];
            [lb setText:@"反馈类型"];
            [lb setTextColor:DEFAULT_FONT_COLOR];
            [cell addSubview:lb];
            
            self.typeLabel=[[UILabel alloc]initWithFrame:CGRectMake(120, 10, SCREEN_WIDTH-150, 44)];
            [self.typeLabel setText:@"关于停车"];
            [self.typeLabel setTag:0];
            [self.typeLabel setTextColor:[UIColor grayColor]];
            [self.typeLabel setTextAlignment:NSTextAlignmentRight];
            [cell addSubview:self.typeLabel];
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            
            cell.selectionStyle=UITableViewCellSelectionStyleDefault;
            break;
        }
        case 1:
        {
            UIView * bg=[[UIView alloc]initWithFrame:CGRectMake(10, 5, bounds.size.width-20, 290)];
            [bg.layer setCornerRadius:5.0];
            [bg.layer setMasksToBounds:YES];
            [bg.layer setBorderColor:[DEFAULT_LINE_COLOR CGColor]];
            [bg.layer setBorderWidth:1.0];
            [cell addSubview:bg];
        
            self.contentField=[[UITextField alloc] initWithFrame:CGRectMake(20, 10, bounds.size.width-40, 280)];
            [self.contentField setTextColor:DEFAULT_FONT_COLOR];
            [self.contentField setAutocorrectionType:UITextAutocorrectionTypeNo];
            [self.contentField setTag:CONTENT_FIELD];
            [self.contentField setPlaceholder:@"请输入反馈内容"];
            [self.contentField setBorderStyle:UITextBorderStyleNone];
            [self.contentField setFont:[UIFont systemFontOfSize:16.0f]];
            [self.contentField setReturnKeyType:UIReturnKeyDone];
            [self.contentField setClearButtonMode:UITextFieldViewModeWhileEditing];
            [self.contentField setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
            [self.contentField setValue:DEFAULT_FONT_COLOR forKeyPath:@"_placeholderLabel.textColor"];
            if (IOS_VERSION_7_OR_ABOVE) {
                [self.contentField setTintColor:DEFAULT_FONT_COLOR];
            }
            
            [self.contentField setDelegate:self];
            [cell addSubview:self.contentField];
            
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            break;
        }
        case 2:
        {
            self.submitButton=[UIButton buttonWithType:UIButtonTypeCustom];
            [self.submitButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
            [self.submitButton setFrame:CGRectMake(20, (80-48)/2, bounds.size.width-40, 48)];
            [self.submitButton setTitle:@"提交" forState:UIControlStateNormal];
            [self.submitButton setTitleColor:DEFAULT_FONT_COLOR forState:UIControlStateNormal];
            [self.submitButton addTarget:self action:@selector(submitRequest:) forControlEvents:UIControlEventTouchUpInside];
            [self.submitButton blueStyle];
            [cell addSubview:self.submitButton];
            
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        }
            break;
        default:
            break;
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row==0) {
        SIAlertView* alertView=[[SIAlertView alloc]initWithTitle:nil andMessage:@"请选择反馈类型"];
        [alertView addButtonWithTitle:@"关于停车" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
            [self.typeLabel setTag:0];
            [self.typeLabel setText:@"关于停车"];
        }];
        [alertView addButtonWithTitle:@"关于缴费" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
            [self.typeLabel setTag:1];
            [self.typeLabel setText:@"关于缴费"];
        }];
        [alertView addButtonWithTitle:@"关于违章" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
            [self.typeLabel setTag:2];
            [self.typeLabel setText:@"关于违章"];
        }];
        [alertView addButtonWithTitle:@"关于服务" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
            [self.typeLabel setTag:3];
            [self.typeLabel setText:@"关于服务"];
        }];
        
        [alertView addButtonWithTitle:@"其他" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
            [self.typeLabel setTag:4];
            [self.typeLabel setText:@"其他"];
        }];
        alertView.transitionStyle=SIAlertViewTransitionStyleSlideFromBottom;
        [alertView show];
    }
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    int tag=[textField tag];
    if(tag==CONTENT_FIELD&&[textField returnKeyType]==UIReturnKeyDone){
        [textField resignFirstResponder];
        [self submit];
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

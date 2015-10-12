//
//  UserViewController.m
//  Parking
//
//  Created by xujunwu on 15/9/16.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "UserViewController.h"
#import "UIViewController+NavigationBarButton.h"
#import "HCurrentUserContext.h"
#import "CollectViewController.h"
#import "ForgetPassController.h"
#import "UIView+LoadingView.h"
#import "UIButton+Bootstrap.h"

@interface UserViewController()


@end


@implementation UserViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setCenterTitle:@"用户信息"];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(onRefresh:)];
    _tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    [self initFootView];
}

-(void)initFootView
{
    UIView* footView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 54)];
    
    UIButton* btn=[[UIButton alloc]initWithFrame:CGRectMake(10, (54-36)/2, SCREEN_WIDTH-20, 36)];
    [btn setTitle:@"退出登录" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn blueStyle];
    [btn addTarget:self action:@selector(onLogout:) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:btn];
    [_tableView setTableFooterView:footView];
    
}

-(IBAction)onLogout:(id)sender
{
    HCurrentUserContext *userContext = [HCurrentUserContext sharedInstance];
    [userContext clearUserInfo];
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(IBAction)onRefresh:(id)sender
{
    HCurrentUserContext *userContext = [HCurrentUserContext sharedInstance];
    __weak UserViewController *myself = self;
    [self.view showHUDLoadingView:YES];
    [userContext getUserInfo:@"" success:^(MKNetworkOperation *completedOperation, id result) {
        [_tableView reloadData];
        [myself.view showHUDLoadingView:NO];
    } error:^(NSError *error) {
        [myself.view showHUDLoadingView:NO];
    } ];
}

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
    
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.accessoryType=UITableViewCellAccessoryNone;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    NSString* title=@"登录帐号:";
    switch (indexPath.row) {
        case 1:
        {
            title=@"昵称:";
            UILabel* val=[[UILabel alloc]initWithFrame:CGRectMake(130,17 , SCREEN_WIDTH-150, 30)];
            [val setText:@"无"];
            [val setTextAlignment:NSTextAlignmentRight];
            [val setTextColor:DEFAULT_FONT_COLOR];
            [val setFont:[UIFont systemFontOfSize:14.0]];
            [cell addSubview:val];
        }
            break;
        case 2:
        {
            title=@"Email:";
            UILabel* val=[[UILabel alloc]initWithFrame:CGRectMake(130,17 , SCREEN_WIDTH-150, 30)];
            [val setText:@"无"];
            [val setTextAlignment:NSTextAlignmentRight];
            [val setTextColor:DEFAULT_FONT_COLOR];
            [val setFont:[UIFont systemFontOfSize:14.0]];
            [cell addSubview:val];
            break;
        }
        case 3:
        {
            title=@"修改密码";
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            
            cell.selectionStyle=UITableViewCellSelectionStyleDefault;
            break;
        }
        case 4:
        {
            title=@"我的收藏";
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle=UITableViewCellSelectionStyleDefault;
            break;
        }
        default:
        {
            UILabel* val=[[UILabel alloc]initWithFrame:CGRectMake(130,17 , SCREEN_WIDTH-150, 30)];
            [val setText:[NSString stringWithFormat:@"%@",[[HCurrentUserContext sharedInstance] username]]];
            [val setTextAlignment:NSTextAlignmentRight];
            [val setTextColor:DEFAULT_FONT_COLOR];
            [val setFont:[UIFont systemFontOfSize:14.0]];
            [cell addSubview:val];
        }
            break;
    }
    cell.textLabel.text=title;
    
    return cell;
}


- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row==3) {
        ForgetPassController* dController=[[ForgetPassController alloc]init];
        dController.dataType=1;
        [self.navigationController pushViewController:dController animated:YES];
    }else if(indexPath.row==4){
        CollectViewController* dController=[[CollectViewController alloc]init];
        dController.cityCode=self.cityCode;
        [self.navigationController pushViewController:dController animated:YES];
    }
}


@end

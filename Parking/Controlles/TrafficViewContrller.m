//
//  TrafficViewContrller.m
//  Parking
//
//  Created by xujunwu on 15/9/16.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "TrafficViewContrller.h"
#import "UIViewController+NavigationBarButton.h"
#import "UIView+LoadingView.h"
#import "WebViewController.h"

@interface TrafficViewContrller()

@end

@implementation TrafficViewContrller


-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setCenterTitle:@"交通公告"];
    _tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    
    [self initHeadView];
    [self loadData];
}

-(void)initHeadView
{
    UIImageView * iv=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 150)];
    [iv setImage:[UIImage imageNamed:@"parking"]];
    [iv setContentMode:UIViewContentModeScaleToFill];
    [_tableView setTableHeaderView:iv];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)loadData
{
    NSString* requestUrl=[NSString stringWithFormat:@"%@notice",kHttpUrl];
    NSMutableDictionary* params=[[NSMutableDictionary alloc]init];
    [self.view showHUDLoadingView:YES];
    [self.networkEngine postOperationWithURLString:requestUrl params:params success:^(MKNetworkOperation *completedOperation, id result) {
        if([[result objectForKey:@"status"] intValue]==200){
                [self parserResponse:result];
        }
        [self.view showHUDLoadingView:NO];
    } error:^(NSError *error) {
        HLog(@"%@",error);
        [self.view showHUDLoadingView:NO];
    }];
}

-(void)parserResponse:(NSDictionary*)result
{
    NSArray* array=[result objectForKey:@"noticeList"];
    if ([array count]>0) {
        [_datas removeAllObjects];
        [_datas addObjectsFromArray:array];
    }
    [_tableView reloadData];
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return [_datas count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    NSDictionary* dict=[_datas objectAtIndex:indexPath.row];
    UILabel*    title=[[UILabel alloc]initWithFrame:CGRectMake(15, 5, SCREEN_WIDTH-30, 30)];
    [title setText:[dict objectForKey:@"noticeTitle"]];
    [title setFont:[UIFont systemFontOfSize:14.0]];
    [title setTextColor:DEFAULT_FONT_COLOR];
    [cell addSubview:title];
    
//    UILabel*    type=[[UILabel alloc]initWithFrame:CGRectMake(10, 32, SCREEN_WIDTH-20, 24)];
//    [type setText:[dict objectForKey:@"notieType"]];
//    [type setFont:[UIFont systemFontOfSize:12.0]];
//    [type setTextColor:DEFAULT_FONT_COLOR];
//    [cell addSubview:type];
    
    UILabel*    time=[[UILabel alloc]initWithFrame:CGRectMake(15, 32, SCREEN_WIDTH-20, 24)];
    [time setText:[[dict objectForKey:@"noticeDate"] substringToIndex:10]];
    [time setFont:[UIFont systemFontOfSize:12.0]];
//    [time setTextAlignment:NSTextAlignmentRight];
    [time setTextColor:DEFAULT_FONT_COLOR];
    [cell addSubview:time];
    
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary* dict=[_datas objectAtIndex:indexPath.row];
    if (dict) {
        WebViewController* dController=[[WebViewController alloc]init];
        dController.infoDict=dict;
        [self.navigationController pushViewController:dController animated:YES];
    }
}


@end

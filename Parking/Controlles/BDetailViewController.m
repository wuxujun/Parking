//
//  BDetailViewController.m
//  Parking
//
//  Created by xujunwu on 15/9/16.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "BDetailViewController.h"
#import "UIViewController+NavigationBarButton.h"
#import "BusViewCell.h"
#import "LineViewController.h"
#import "NaviViewController.h"
#import "StringUtil.h"


@interface BDetailViewController()


@property(nonatomic,strong)AMapSearchAPI    *searchAPI;

@end

@implementation BDetailViewController
@synthesize startPoint;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchAPI=[[AMapSearchAPI alloc]initWithSearchKey:AMAP_KEY Delegate:self];
    
    if (self.infoDict) {
        [self setCenterTitle:[self.infoDict objectForKey:@"name"]];
        HLog(@"%@",[self.infoDict objectForKey:@"uid"]);
        AMapBusLineSearchRequest* lineRequest=[[AMapBusLineSearchRequest alloc]init];
        lineRequest.uid=[self.infoDict objectForKey:@"uid"];
        lineRequest.searchType=AMapSearchType_LineID;
        lineRequest.requireExtension=YES;
        [self.searchAPI AMapBusLineSearch:lineRequest];
    }
    _tableView.frame=CGRectMake(0, 88, self.view.frame.size.width, self.view.frame.size.height-88);
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    [self initHeadView];
}

-(void)initHeadView
{
    UIView * view=[[UIView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 88)];
    [view setBackgroundColor:[UIColor whiteColor]];
    
    UILabel* lb=[[UILabel alloc]initWithFrame:CGRectMake(10, 8, self.view.frame.size.width-20, 40)];
    [lb setText: [NSString stringWithFormat:@"%@->%@",[self.infoDict objectForKey:@"startName"],[self.infoDict objectForKey:@"endName"]]];
    [lb setFont:[UIFont boldSystemFontOfSize:25.0]];
    [view addSubview:lb];
    
    UILabel* startTime=[[UILabel alloc] initWithFrame:CGRectMake(30, 50, 40, 30)];
    startTime.textColor=DEFAULT_FONT_COLOR;
    [startTime setFont:[UIFont systemFontOfSize:12.0f]];
    [startTime setText:[self.infoDict objectForKey:@"startTime"]];
    [view addSubview:startTime];
    
    UILabel*  endTime=[[UILabel alloc] initWithFrame:CGRectMake(100, 50, 40, 30)];
    endTime.textColor=DEFAULT_FONT_COLOR;
    endTime.font=[UIFont systemFontOfSize:12.0f];
    [endTime setText:[self.infoDict objectForKey:@"endTime"]];
    [view addSubview:endTime];
    
    UIImageView* startIV=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"default_path_bustime_start_normal"]];
    [startIV setFrame:CGRectMake(10, 56, 18, 18)];
    [view addSubview:startIV];
    
    UIImageView* endIV=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"default_path_bustime_end_normal"]];
    [endIV setFrame:CGRectMake(80, 56, 18, 18)];
    [view addSubview:endIV];
    
    UILabel* ds=[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-10, 50, self.view.frame.size.width/2, 30)];
    [ds setText:[NSString stringWithFormat:@"全程:%.0f公里 票价:%@元",[[self.infoDict objectForKey:@"distance"] floatValue],[self.infoDict objectForKey:@"price"]]];
    [ds setFont:[UIFont systemFontOfSize:12.0f]];
    [ds setTextAlignment:NSTextAlignmentRight];
    
    UIImageView *line=[[UIImageView alloc] initWithFrame:CGRectMake(0, 87, self.view.frame.size.width, 1.0f)];
    [line setBackgroundColor:DEFAULT_LINE_COLOR];
    [view addSubview:line];
    
    [view addSubview:ds];
    [self.view addSubview:view];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}

-(void)onBusLineSearchDone:(AMapBusLineSearchRequest *)request response:(AMapBusLineSearchResponse *)response
{
    if (response.buslines.count==0) {
        return;
    }
    for (AMapBusLine *p in response.buslines) {
        //        HLog(@"%@", p.description);
        for (AMapBusStop *s in p.busStops) {
            NSDictionary* dict=[NSDictionary dictionaryWithObjectsAndKeys:s.name,@"name", nil];
            [_datas addObject:dict];
        }
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
    return 44.0f;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return [_datas count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSDictionary *dict=[_datas objectAtIndex:indexPath.row];
    if (dict) {
        UILabel *lb=[[UILabel alloc]initWithFrame:CGRectMake(40, 7, self.view.frame.size.width-50, 30)];
        [lb setText:[dict objectForKey:@"name"]];
        [cell addSubview:lb];
        
    }
    if (indexPath.row==0) {
        UIImageView *iv=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_busnavi_preview_start"]];
        [iv setFrame:CGRectMake(10, 13, 18, 18)];
        [cell addSubview:iv];
        
    }else if (indexPath.row==([_datas count]-1)) {
        UIImageView *iv=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_busnavi_preview_end"]];
        [iv setFrame:CGRectMake(10, 13, 18, 18)];
        [cell addSubview:iv];
        
    }else{
        UIImageView *iv=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_busline_icon_site"]];
        [iv setFrame:CGRectMake(10, 13, 18, 18)];
        [cell addSubview:iv];
    }
    UIImageView *ivTop=[[UIImageView alloc] initWithFrame:CGRectMake(18, 0, 2, 13)];
    [ivTop setBackgroundColor:[UIColor grayColor]];
    [cell addSubview:ivTop];
    
    UIImageView *ivDown=[[UIImageView alloc] initWithFrame:CGRectMake(18, 13+18, 2, 13)];
    [ivDown setBackgroundColor:[UIColor grayColor]];
    [cell addSubview:ivDown];
    
    UIImageView *line=[[UIImageView alloc] initWithFrame:CGRectMake(40, 42, self.view.frame.size.width-40, 0.5f)];
    [line setBackgroundColor:DEFAULT_LINE_COLOR];
    [cell addSubview:line];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

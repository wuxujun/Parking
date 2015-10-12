//
//  BListViewController.m
//  Parking
//
//  Created by xujunwu on 15/9/16.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "BListViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIViewController+NavigationBarButton.h"
#import "BusViewCell.h"
#import "LineViewController.h"
#import "NaviViewController.h"
#import "BDetailViewController.h"
#import "NaviViewController.h"
#import "SIAlertView.h"

@interface BListViewController()
{
    
}


@property(nonatomic,strong)AMapSearchAPI    *searchAPI;

@end

@implementation BListViewController
@synthesize startPoint;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchAPI=[[AMapSearchAPI alloc]initWithSearchKey:AMAP_KEY Delegate:self];
    
    NSString *content=@"";
    if (self.infoDict) {
        [self setCenterTitle:[self.infoDict objectForKey:@"title"]];
        content=[self.infoDict objectForKey:@"address"];
    }
    
    if(content.length>0){
        NSArray *array=[content componentsSeparatedByString:@";"];
        for (int i=0; i<[array count]; i++) {
            AMapBusLineSearchRequest* lineRequest=[[AMapBusLineSearchRequest alloc]init];
            lineRequest.keywords=[array objectAtIndex:i];
            lineRequest.city=@[self.cityCode];
            lineRequest.requireExtension=YES;
            [self.searchAPI AMapBusLineSearch:lineRequest];
        }
    }
//    _tableView.frame=CGRectMake(0, 88, self.view.frame.size.width, self.view.frame.size.height-88);
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self initHeadView];
}

-(void)initHeadView
{
    UIView* bg=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 88)];
    [bg setBackgroundColor:[UIColor whiteColor]];
    
    UIView * view=[[UIView alloc]initWithFrame:CGRectMake(10, 4, self.view.frame.size.width-20, 80)];
    [view setBackgroundColor:DEFAULT_NAVIGATION_BACKGROUND_COLOR];
    [view.layer setMasksToBounds:YES];
    [view.layer setCornerRadius:4.0f];
    [bg addSubview:view];
    
    UILabel* lb=[[UILabel alloc]initWithFrame:CGRectMake(10, 10, self.view.frame.size.width-20, 40)];
    [lb setText: [NSString stringWithFormat:@"%@",[self.infoDict objectForKey:@"title"]]];
    [lb setTextColor:[UIColor whiteColor]];
    [lb setFont:[UIFont boldSystemFontOfSize:22.0]];
    [view addSubview:lb];
    
    UILabel* distance=[[UILabel alloc] initWithFrame:CGRectMake(30, 50, 100, 30)];
    distance.textColor=[UIColor whiteColor];
    [distance setFont:[UIFont systemFontOfSize:14.0f]];
    [distance setText:@"100米"];
    [view addSubview:distance];
    
    UIButton* naviBtn=[[UIButton alloc]initWithFrame:CGRectMake(view.frame.size.width-60, 5, 50, 70)];
    [naviBtn setBackgroundColor:[UIColor clearColor]];
    [naviBtn addTarget:self action:@selector(onStartNavi:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:naviBtn];
    
    UIImageView* lineIV=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"default_main_toolbaritem_path_normal"]];
    [lineIV setFrame:CGRectMake(view.frame.size.width-50,15, 30, 30)];
    [view addSubview:lineIV];
    
    UILabel*  navi=[[UILabel alloc] initWithFrame:CGRectMake(view.frame.size.width-75, view.frame.size.height/2+5, 80, 30)];
    navi.textColor=[UIColor whiteColor];
    [navi setTextAlignment:NSTextAlignmentCenter];
    navi.font=[UIFont systemFontOfSize:14.0f];
    [navi setText:@"去这里"];
    [view addSubview:navi];
    
    UIImageView *line=[[UIImageView alloc] initWithFrame:CGRectMake(view.frame.size.width-75, view.frame.size.height/2-20, 0.3f, 40.0f)];
    [line setBackgroundColor:DEFAULT_LINE_COLOR];
    [view addSubview:line];
    
    [_tableView setTableHeaderView:bg];
}


-(IBAction)onStartNavi:(id)sender
{
    
    SIAlertView* alertView=[[SIAlertView alloc]initWithTitle:nil andMessage:@"请选择导航类型:"];
    [alertView addButtonWithTitle:@"驾车" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
       [self openNavi:1];
    }];
    [alertView addButtonWithTitle:@"步行" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
        [self openNavi:2];
    }];
    [alertView addButtonWithTitle:@"取消" type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
    
    }];
    alertView.transitionStyle=SIAlertViewTransitionStyleSlideFromBottom;
    [alertView show];
    
   
}

-(void)openNavi:(NSInteger)type
{
    NaviViewController* dController=[[NaviViewController alloc]init];
    dController.naviType=type;
    dController.startPoint=self.startPoint;
    dController.endPoint=self.infoDict;
    [self.navigationController pushViewController:dController animated:YES];
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
    NSDictionary* dc=[NSDictionary dictionaryWithObjectsAndKeys:@"0",@"type",request.keywords,@"name", nil];
    [_datas addObject:dc];
    
    for (AMapBusLine *p in response.buslines) {
//        HLog(@"%@", p.description);
        NSDictionary* dict=[NSDictionary dictionaryWithObjectsAndKeys:p.uid,@"uid",p.name,@"name",[p.startStop name],@"startName",[p.endStop name],@"endName",p.startTime,@"startTime",p.endTime ,@"endTime",[NSNumber  numberWithFloat:p.distance],@"distance",[NSNumber  numberWithFloat:p.basicPrice],@"price",@"1",@"type", nil];
        HLog(@"%@",dict);
        [_datas addObject:dict];
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
        if ([[dict objectForKey:@"type"] isEqualToString:@"0"]) {
            cell.textLabel.text=[dict objectForKey:@"name"];
        }else{
            BusViewCell* item=[[BusViewCell alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
            item.infoDict=dict;
            [cell addSubview:item];
        }
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary* dict=[_datas objectAtIndex:indexPath.row];
    if (dict) {
        if ([[dict objectForKey:@"type"] isEqualToString:@"1"]) {
            BDetailViewController* dController=[[BDetailViewController alloc]init];
            dController.infoDict=dict;
            [self.navigationController pushViewController:dController animated:YES];
        }
    }
}

@end

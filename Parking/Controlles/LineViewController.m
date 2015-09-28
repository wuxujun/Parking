//
//  LineViewController.m
//  Parking
//
//  Created by xujunwu on 15/9/1.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "LineViewController.h"
#import "NaviViewController.h"
#import "UIViewController+NavigationBarButton.h"

@interface LineViewController ()

@property(nonatomic,strong)AMapSearchAPI    *searchAPI;
@property(nonatomic,strong)AMapRoute        *route;


@end

@implementation LineViewController
@synthesize lineType=_lineType;
@synthesize startPoint=_startPoint;
@synthesize endPoint=_endPoint;



-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setCenterTitle:@"线路详情"];
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"导航" style:UIBarButtonItemStylePlain target:self action:@selector(showMap:)];
    self.searchAPI=[[AMapSearchAPI alloc]initWithSearchKey:AMAP_KEY Delegate:self];
    _tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self serarchLine];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)showMap:(id)sender
{
    NaviViewController* dController=[[NaviViewController alloc]init];
    dController.naviType=1;
    [dController setStartPoint:self.startPoint];
    [dController setEndPoint:self.endPoint];
    [self.navigationController pushViewController:dController animated:YES];
}

-(void)serarchLine
{
    [self reloadData];
    AMapNavigationSearchRequest* request=[[AMapNavigationSearchRequest alloc]init];
    switch (self.lineType) {
        case 1:
            request.searchType=AMapSearchType_NaviDrive;
            break;
        case 2:
            request.searchType=AMapSearchType_NaviWalking;
            break;
        case 3:
            request.searchType=AMapSearchType_NaviBus;
            break;
        default:
            request.searchType=AMapSearchType_NaviDrive;
            break;
    }
    HLog(@"%@ \n %@",self.startPoint,self.endPoint);
    request.requireExtension=YES;
    request.origin=[AMapGeoPoint locationWithLatitude:[[self.startPoint objectForKey:@"latitude"] floatValue] longitude:[[self.startPoint objectForKey:@"longitude"] floatValue] ];
    request.destination=[AMapGeoPoint locationWithLatitude:[[self.endPoint objectForKey:@"latitude"] floatValue] longitude:[[self.endPoint objectForKey:@"longitude"] floatValue] ];
    [self.searchAPI AMapNavigationSearch:request];
    
}

-(void)onNavigationSearchDone:(AMapNavigationSearchRequest *)request response:(AMapNavigationSearchResponse *)response
{
    if (response.route==nil) {
        return;
    }
    [_datas removeAllObjects];
    self.route=response.route;
    AMapPath *path=[self.route.paths objectAtIndex:0];
    [_datas addObjectsFromArray:path.steps];
    [_tableView reloadData];
    [loading removeFromSuperview];
    loading=nil;
}

-(void)searchRequest:(id)request didFailWithError:(NSError *)error
{
    HLog(@"%@   %@",[request class],error);
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0||section==2) {
        return 1;
    }
    return [_datas count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    if (indexPath.section==0||indexPath.section==2) {
        UIImageView* iv=[[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 34, 34)];
        if (indexPath.section==0) {
            [iv setImage:[UIImage imageNamed:@"start"]];
        }else{
            [iv setImage:[UIImage imageNamed:@"end"]];
        }
        [cell addSubview:iv];
        
        UILabel* lb=[[UILabel alloc]initWithFrame:CGRectMake(50, 5, self.view.frame.size.width-60, 40)];
        [lb setNumberOfLines:0];
        [lb setFont:[UIFont systemFontOfSize:14.0f]];
        [lb setLineBreakMode:NSLineBreakByWordWrapping];
        if (indexPath.section==0) {
            [lb setText:@"我的位置"];
        }else{
            [lb setText:@"终点"];
        }
        [cell addSubview:lb];
    }else{
        AMapStep* setp=[_datas objectAtIndex:indexPath.row];
        if (setp) {
            UIImageView* iv=[[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 34, 34)];
            if ([setp.action isEqualToString:@"左转"]) {
                [iv setImage:[UIImage imageNamed:@"map_route_turn_left"]];
        }else if([setp.action isEqualToString:@"右转"]){
            [iv setImage:[UIImage imageNamed:@"map_route_turn_right"]];
        }else if([setp.action isEqualToString:@"向左前方行驶"]||[setp.action isEqualToString:@"靠左"]){
            [iv setImage:[UIImage imageNamed:@"map_route_turn_left_front"]];
        }else if([setp.action isEqualToString:@"向右前方行驶"]||[setp.action isEqualToString:@"靠右"]){
            [iv setImage:[UIImage imageNamed:@"map_route_turn_right_front"]];
        }else if([setp.action isEqualToString:@"向左后方行驶"]||[setp.action isEqualToString:@"左转调头"]){
            [iv setImage:[UIImage imageNamed:@"map_route_turn_left_back"]];
        }else if([setp.action isEqualToString:@"向右后方行驶"]){
            [iv setImage:[UIImage imageNamed:@"map_route_turn_right_back"]];
        }else if([setp.action isEqualToString:@"直行"]){
            [iv setImage:[UIImage imageNamed:@"map_route_turn_front"]];
        }else if([setp.action isEqualToString:@"减速行驶"]){
            [iv setImage:[UIImage imageNamed:@"map_route_turn_undefine"]];
        }else{
            [iv setImage:[UIImage imageNamed:@"map_route_turn_front"]];
        }
        [cell addSubview:iv];
        
        UILabel* lb=[[UILabel alloc]initWithFrame:CGRectMake(50, 5, self.view.frame.size.width-60, 40)];
        [lb setNumberOfLines:0];
        [lb setFont:[UIFont systemFontOfSize:14.0f]];
        [lb setLineBreakMode:NSLineBreakByWordWrapping];
        [lb setText:setp.instruction];
        [cell addSubview:lb];
    }
    }
    return cell;
}


@end

//
//  MenuViewController.m
//  Parking
//
//  Created by xujunwu on 15/8/30.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "MenuViewController.h"
#import "MenuHeadView.h"
#import "UIViewController+REFrostedViewController.h"

@interface MenuViewController ()<MenuHeadViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray      *data;
    
    MenuHeadView        *headView;
    
    UITableView         *_tableView;
}

@end

@implementation MenuViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    data=[[NSMutableArray alloc]init];
    
    headView=[[MenuHeadView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 140) delegate:self];
    [self.view addSubview:headView];
    
    if (_tableView==nil) {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 140, SCREEN_WIDTH, SCREEN_HEIGHT-140)];
        _tableView.dataSource=self;
        _tableView.delegate=self;
        _tableView.showsVerticalScrollIndicator=NO;
        _tableView.opaque=NO;
        _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor=[UIColor whiteColor];
        [self.view addSubview:_tableView];
    }
    
    [self loadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [headView reloadData];
    
}

-(void)loadData
{
    [data addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"高级搜索",@"title",@"0",@"type",@"ic_menu_search",@"image", nil]];
    [data addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"交通公告",@"title",@"1",@"type",@"ic_menu_notice",@"image", nil]];
    [data addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"预定车位",@"title",@"2",@"type",@"ic_menu_yd",@"image", nil]];
    [data addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"车位记录",@"title",@"3",@"type",@"ic_menu_query",@"image", nil]];
    [data addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"设置",@"title",@"4",@"type",@"ic_menu_set",@"image", nil]];
    [data addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"操作指南",@"title",@"5",@"type",@"ic_menu_guide",@"image", nil]];
    [data addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"推荐给好友",@"title",@"6",@"type",@"ic_menu_share",@"image", nil]];
    [data addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"反馈有奖",@"title",@"7",@"type",@"ic_menu_feedback",@"image", nil]];
    [data addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"关于我们",@"title",@"8",@"type",@"ic_menu_about",@"image", nil]];
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return [data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSDictionary* dic=[data objectAtIndex:indexPath.row];
    [cell.textLabel setText:[dic objectForKey:@"title"]];
    [cell.imageView setImage:[UIImage imageNamed:[dic objectForKey:@"image"]]];

    UIImageView* line=[[UIImageView alloc] initWithFrame:CGRectMake(55, 53, SCREEN_WIDTH-55, 0.5)];
    [line setBackgroundColor:DEFAULT_LINE_COLOR];
    [cell addSubview:line];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary* dict=[data objectAtIndex:indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_OPEN_TYPE object:dict];
    [self.frostedViewController hideMenuViewController];
}


-(void)onMenuHeadViewClicked:(int)idx
{
    NSDictionary* dict=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:(idx+100)],@"type", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_OPEN_TYPE object:dict];
    [self.frostedViewController hideMenuViewController];
}

@end

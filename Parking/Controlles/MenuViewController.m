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

@interface MenuViewController ()<MenuHeadViewDelegate>
{
    NSMutableArray      *data;
    
    MenuHeadView        *headView;
}

@end

@implementation MenuViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    data=[[NSMutableArray alloc]init];
    
    headView=[[MenuHeadView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 140) delegate:self];
    [self.tableView setTableHeaderView:headView];
    self.tableView.showsVerticalScrollIndicator=NO;
    self.tableView.separatorColor = [UIColor grayColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor =DEFAULT_NAVIGATION_BACKGROUND_COLOR;

    [self loadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [headView reloadData];
    
}

-(void)loadData
{
    [data addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"交通公告",@"title",@"1",@"type",@"ic_menu_notice",@"image", nil]];
    [data addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"预定车位",@"title",@"2",@"type",@"ic_menu_yd",@"image", nil]];
    [data addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"反向寻车",@"title",@"3",@"type",@"ic_menu_query",@"image", nil]];
    [data addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"设置",@"title",@"4",@"type",@"ic_menu_set",@"image", nil]];
    [data addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"操作指南",@"title",@"5",@"type",@"ic_menu_guide",@"image", nil]];
    [data addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"推荐给好友",@"title",@"6",@"type",@"ic_menu_share",@"image", nil]];
    [data addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"有奖反馈",@"title",@"7",@"type",@"ic_menu_feedback",@"image", nil]];
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

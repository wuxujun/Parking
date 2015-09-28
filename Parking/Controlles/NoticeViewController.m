//
//  NoticeViewController.m
//  Parking
//
//  Created by xujunwu on 15/9/16.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "NoticeViewController.h"
#import "UIViewController+NavigationBarButton.h"

@interface NoticeViewController()

@end

@implementation NoticeViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setCenterTitle:@"消息中心"];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStylePlain target:self action:@selector(onClear:)];
    _tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
}

-(void)loadData
{
    NSString* fileName=@"notice";
    NSData *jsdata = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"json"]];
    @autoreleasepool {
        
        if (jsdata)
        {
            NSArray *dicArray = [NSJSONSerialization JSONObjectWithData:jsdata options:NSJSONReadingAllowFragments error:nil];
            
            for (NSDictionary *dic in dicArray)
            {
                [_datas addObject:dic];
            }
            [_tableView reloadData];
        }
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadData];
}

-(IBAction)onClear:(id)sender
{
    
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
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
    UILabel*    title=[[UILabel alloc]initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH-20, 30)];
    [title setText:[dict objectForKey:@"title"]];
    [title setFont:[UIFont systemFontOfSize:14.0]];
    [title setTextColor:DEFAULT_FONT_COLOR];
    [cell addSubview:title];
    
    UILabel*    content=[[UILabel alloc]initWithFrame:CGRectMake(10, 35, SCREEN_WIDTH-20, 40)];
    [content setText:[dict objectForKey:@"content"]];
    [content setFont:[UIFont systemFontOfSize:12.0]];
    [content setNumberOfLines:0];
    [content setLineBreakMode:NSLineBreakByCharWrapping];
    [content setTextColor:DEFAULT_FONT_COLOR];
    [cell addSubview:content];
    
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

@end

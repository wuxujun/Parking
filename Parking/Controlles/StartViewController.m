//
//  StartViewController.m
//  Parking
//
//  Created by xujunwu on 15/10/10.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import "StartViewController.h"
#import "UserDefaultHelper.h"
#import "AppDelegate.h"

@interface StartViewController ()
{
    UIImageView         *bgView;
    UIImageView         *pointView;
    UIImageView         *iconView;
    
    BOOL            upOrDown;
    NSTimer         *timer;
}

@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    bgView=[[UIImageView alloc]initWithFrame:self.view.bounds];
    [bgView setImage:[UIImage imageNamed:@"LaunchImage"]];
    [bgView setContentMode:UIViewContentModeScaleToFill];
    
//    iconView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    
    pointView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ic_start_bg"]];
    [pointView setFrame:CGRectMake(5, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [pointView setContentMode:UIViewContentModeScaleToFill];
    
    iconView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ic_start_icon"]];
    [iconView setFrame:CGRectMake(0, -30, self.view.frame.size.width, self.view.frame.size.height)];
    [iconView setContentMode:UIViewContentModeScaleToFill];
    
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.scrollEnabled=NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startScan];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (timer) {
        [timer invalidate];
    }
}

-(void)startScan
{
    timer=[NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(animationUpOrDown) userInfo:nil repeats:YES];
}

-(void)animationUpOrDown
{
    if (upOrDown==NO) {
        iconView.frame=CGRectMake(iconView.frame.origin.x,iconView.frame.origin.y+10, iconView.frame.size.width, iconView.frame.size.height);
        upOrDown=YES;
    }else{
        iconView.frame=CGRectMake(iconView.frame.origin.x,iconView.frame.origin.y-10, iconView.frame.size.width, iconView.frame.size.height);
        upOrDown=NO;
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREEN_HEIGHT;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    }
    [cell addSubview:bgView];
    [cell addSubview:pointView];
    [cell addSubview:iconView];
    cell.accessoryType=UITableViewCellAccessoryNone;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BOOL firstOpen=[[UserDefaultHelper objectForKey:PRE_FIRST_OPEN] boolValue];
    if (firstOpen) {
        [ApplicationDelegate openIntroduction:0];
    }else{
        [ApplicationDelegate openHomeView];
    }
    
}

@end

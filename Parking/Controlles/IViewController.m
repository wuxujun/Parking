//
//  IViewController.m
//  Parking
//
//  Created by xujunwu on 15/9/17.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import "IViewController.h"
#import "SIAlertView.h"
#import "HKeyboardTableView.h"

@interface IViewController ()<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate>

@end


@implementation IViewController
@synthesize infoDict,dataType;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _datas=[[NSMutableArray alloc]init];
    
    UIBarButtonItem* backBtn=[[UIBarButtonItem alloc]init];
    backBtn.title=@"返回";
    self.navigationItem.backBarButtonItem=backBtn;
    if (self.infoDict) {
        self.navigationItem.title=[self.infoDict objectForKey:@"title"];
    }
    
    if(_tableView==nil){
        _tableView=[[HKeyboardTableView alloc]initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
        _tableView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _tableView.delegate=self;
        _tableView.dataSource=self;
        _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //    [self showNavBarAnimated:NO];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 0;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MBProgressHUDDelegate
-(void)hudWasHidden:(MBProgressHUD *)hud
{
    [loading removeFromSuperview];
    loading=nil;
}

-(void)reloadData
{
    if (loading==nil) {
        loading=[[MBProgressHUD alloc]initWithView:self.view];
        loading.delegate=self;
        loading.labelText=@"数据加载中.请稍候...";
    }
    BOOL isExits=false;
    for (UIView *v in [self.view subviews]) {
        if ([v isKindOfClass:[MBProgressHUD class]]) {
            isExits=true;
        }
    }
    if (!isExits) {
        [self.view addSubview:loading];
    }
    [loading show:YES];
    
}

-(void)reloadData:(NSString*)message
{
    if (loading==nil) {
        loading=[[MBProgressHUD alloc]initWithView:self.view];
        loading.delegate=self;
    }
    loading.labelText=message;
    BOOL isExits=false;
    for (UIView *v in [self.view subviews]) {
        if ([v isKindOfClass:[MBProgressHUD class]]) {
            isExits=true;
        }
    }
    if (!isExits) {
        [self.view addSubview:loading];
    }
    [loading show:YES];
    
}


-(void)loadData:(NSNotification *)sender
{
    [loading removeFromSuperview];
    loading=nil;
}

-(void)requestFailed:(NSNotification*)sender
{
    [loading removeFromSuperview];
    loading=nil;
    //    [self alertRequestResult:@"网络请求失败,稍后再试"];
}

#pragma mark - 网络请求成功返回提示，及下步操作
-(void)alertRequestResult:(NSString*)message
{
    SIAlertView *alertView=[[SIAlertView alloc]initWithTitle:nil andMessage:message];
    [alertView addButtonWithTitle:@"2秒后自动关闭" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView){
        [alertView dismissAnimated:YES];
    }];
    [alertView show];
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [alertView dismissAnimated:YES];
    });
    
}

@end

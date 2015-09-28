//
//  BaseViewController.m
//  Woicar
//
//  Created by xujun wu on 13-5-26.
//  Copyright (c) 2013年 xujun wu. All rights reserved.
//

#import "BaseViewController.h"
#import "SIAlertView.h"

@interface BaseViewController ()<UIActionSheetDelegate,UIAlertViewDelegate,MBProgressHUDDelegate>
{
    UIAlertView         *alertView;
}

@end

@implementation BaseViewController
@synthesize categoryId,infoDict;

-(id)init
{
    self=[super init];
    if (self) {
        
    }
    return self;
}

-(void)setUpRefreshView
{
    if (_refreshHeaderView==nil) {
        EGORefreshTableHeaderView *view=[[EGORefreshTableHeaderView alloc]initWithFrame:CGRectMake(0, 0.0f-mTableView.bounds.size.height, self.view.frame.size.width, mTableView.bounds.size.height)];
        view.delegate=self;
        [mTableView addSubview:view];
        _refreshHeaderView=view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _datas=[[NSMutableArray alloc]init];
    
    if (IOS_VERSION_7_OR_ABOVE) {
        self.navigationController.navigationBar.barTintColor=DEFAULT_NAVIGATION_BACKGROUND_COLOR;
    }
    
    if (self.infoDict) {
        self.navigationItem.title=[self.infoDict objectForKey:@"title"];
    }
    
 
    [self setUpRefreshView];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(BOOL)prefersStatusBarHidden
{
    return NO;
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

-(IBAction)queryAction:(id)sender
{
    
}

-(void)setBarButton
{
}

-(void)refreshData
{
    _loadingOver=NO;
    [self reload:NO];
}

-(void)clear
{
    [_datas removeAllObjects];
    _loadingOver = NO;
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
}

-(void)tips
{

}

#pragma mark - 网络请求成功返回提示，及下步操作
-(void)alertRequestResult:(NSString*)message
{
    SIAlertView *alertView=[[SIAlertView alloc]initWithTitle:nil andMessage:message];
    
    [alertView addButtonWithTitle:@"2秒后自动关闭" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView){
        
    }];
    [alertView show];
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [alertView dismissAnimated:YES];
        
    });
    
}

-(void)parserData:(NSDictionary *)aDict userInfo:(NSDictionary *)aUserInfo
{
    _page=[[aDict objectForKey:@"pageIndex"] intValue];
    _rownums=[[aDict objectForKey:@"rowNums"] intValue];
    _pageSize=[[aDict objectForKey:@"pageSize"]intValue];
    
    HLog(@"parserData :%d  %d   %d",_page,_rownums,_pageSize);
    NSArray *array=[aDict objectForKey:@"root"];
    for (int index=0; index<[array count]; index++) {
        [_datas addObject:[array objectAtIndex:index]];
    }
    if ([_datas count]>=_rownums) {
        [mTableView setTableFooterView:nil];
    }
    
    [self stopLoading];
    isLoading=NO;
    [self doneLoadingTableViewData];
    
    [mTableView reloadData];
    
}

#pragma mark - 排序
+(void)changeArray:(NSMutableArray*)aDict orderWithKey:(NSString*)key ascending:(BOOL)flag
{
    NSSortDescriptor *dd=[[NSSortDescriptor alloc]initWithKey:key ascending:flag];
    NSArray *ds=[NSArray arrayWithObjects:dd, nil];
    [aDict sortUsingDescriptors:ds];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)reloadTableViewDataSource
{
    _reloading=YES;
}

-(void)doneLoadingTableViewData
{
    _reloading=NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:mTableView];
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y<200) {
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }else{
        [super scrollViewDidScroll:scrollView];
    }
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y<200) {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }else{
        [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

#pragma mark - EGORefreshTableHeaderDelegate

-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    _reloading=YES;
    [self refreshData];
}

-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return _reloading;
}

-(NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}

#pragma mark - MBProgressHUDDelegate
-(void)hudWasHidden:(MBProgressHUD *)hud
{
    [loading removeFromSuperview];
    loading=nil;
}

@end

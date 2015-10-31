//
//  IntroductionController.m
//  Parking
//
//  Created by xujunwu on 15/9/7.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "IntroductionController.h"
#import "UIViewController+NavigationBarButton.h"
#import "AppDelegate.h"
#import "PhotoViewController.h"
#import "DMLazyScrollView.h"
#import "UserDefaultHelper.h"

@interface IntroductionController()<DMLazyScrollViewDelegate>
{
    DMLazyScrollView    *mScrollView;
    NSMutableArray      *photoDatas;
    NSMutableArray      *viewControllerArray;

    NSInteger           currentPage;
    NSInteger           endPage;
}

@end

@implementation IntroductionController

@synthesize dataType=_dataType;


-(void)viewDidLoad
{
    [super viewDidLoad];

    photoDatas=[[NSMutableArray alloc]init];
    viewControllerArray=[[NSMutableArray alloc] initWithCapacity:10];
    for (NSUInteger k=0 ; k<10; ++k) {
        [viewControllerArray addObject:[NSNull null]];
    }
   
    if (mScrollView==nil) {
        mScrollView=[[DMLazyScrollView alloc] initWithFrame:self.view.bounds];
        mScrollView.controlDelegate=self;
        [mScrollView setEnableCircularScroll:NO];
        [mScrollView setAutoPlay:NO];
        
        [self.view addSubview:mScrollView];
    }
    
    if (self.dataType==1) {
        [self setCenterTitle:@"操作指南"];
        [self addBackBarButton];
//        UIButton * back=[[UIButton alloc] initWithFrame:CGRectMake(0, 20, 100, 60)];
//        [back setTitle:@"返回" forState:UIControlStateNormal];
//        [back.titleLabel setTextAlignment:NSTextAlignmentCenter];
//        [back setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [back setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
//        [back addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:back];
    }else{
        UIButton * back=[[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-100, 20, 100, 60)];
        [back setTitle:@"跳过>>" forState:UIControlStateNormal];
        [back.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [back setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [back setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        [back addTarget:self action:@selector(onOpenHome:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:back];
    }
    
    __weak __typeof(&*self)weakSel=self;
    mScrollView.dataSource=^(NSUInteger index){
        return [weakSel controllerAtIndex:index];
    };

}

-(IBAction)onOpenHome:(id)sender
{
    [UserDefaultHelper setObject:[NSNumber numberWithBool:false] forKey:PRE_FIRST_OPEN];
    [ApplicationDelegate openHomeView];
}

-(IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

-(UIViewController*)controllerAtIndex:(NSInteger)index
{
    if (index>photoDatas.count||index<0) {
        return nil;
    }
    
    id res=[viewControllerArray objectAtIndex:index%10];
    NSDictionary* dict=[photoDatas objectAtIndex:index];
    if (res==[NSNull null]) {
        PhotoViewController* viewController=[[PhotoViewController alloc]init];
        viewController.infoDict=dict;
        [viewControllerArray replaceObjectAtIndex:index%10 withObject:viewController];
        return viewController;
    }
    [(PhotoViewController*)res setInfoDict:dict];
    [(PhotoViewController*)res refresh];
    return res;
}


-(void)loadData
{
    for (int i=0; i<4; i++) {
        NSDictionary* dict=[NSDictionary dictionaryWithObjectsAndKeys:@"2",@"dataType",[NSString stringWithFormat:@"intruduce_%d",i],@"image", nil];
        [photoDatas addObject:dict];
    }
    mScrollView.numberOfPages=4;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)lazyScrollView:(DMLazyScrollView *)pagingView currentPageChanged:(NSInteger)currentPageIndex
{
    HLog(@"%d",currentPageIndex);
    currentPage=currentPageIndex;
    endPage=0;
}

-(void)lazyScrollViewDidEndDecelerating:(DMLazyScrollView *)pagingView atPageIndex:(NSInteger)pageIndex
{
    HLog(@"%d",pageIndex);
    if (pageIndex==currentPage) {
        endPage++;
    }
    if (endPage==2) {
        [self performSelector:@selector(openHomeView) withObject:nil afterDelay:0.5];
    }
}

-(void)openHomeView
{
    [UserDefaultHelper setObject:[NSNumber numberWithBool:false] forKey:PRE_FIRST_OPEN];
    [ApplicationDelegate openHomeView];
}

@end

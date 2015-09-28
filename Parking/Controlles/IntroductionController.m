//
//  IntroductionController.m
//  Parking
//
//  Created by xujunwu on 15/9/7.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "IntroductionController.h"

@interface IntroductionController()<UIScrollViewDelegate>
{
    
    UIScrollView    * mScrollView;
    
}


@end

@implementation IntroductionController

@synthesize dataType=_dataType;


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView* bg=[[UIView alloc]initWithFrame:SCREEN_SIZE];
    [bg setBackgroundColor:DEFAULT_NAVIGATION_BACKGROUND_COLOR];
    if (mScrollView==nil) {
        mScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
//        mScrollView.pagingEnabled=YES;
        mScrollView.delegate=self;
        mScrollView.showsVerticalScrollIndicator=NO;
        mScrollView.showsHorizontalScrollIndicator=NO;
        mScrollView.alwaysBounceVertical=NO;
        [bg addSubview:mScrollView];
    }
    
    [self.view addSubview:bg];
    if (self.dataType==1) {
        UIButton * back=[[UIButton alloc] initWithFrame:CGRectMake(10, 36, 80, 30)];
        [back setTitle:@"返回" forState:UIControlStateNormal];
        [back setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [back addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:back];
    }
}

-(IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self loadData];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(BOOL)prefersStatusBarHidden
{
    return NO;
}

-(void)loadData
{
    for (int i=0; i<4; i++) {
        UIImageView* iv=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"intruduce_%d",i]]];
        [iv setFrame:CGRectMake(i*SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [iv setContentMode:UIViewContentModeScaleToFill];
        [mScrollView addSubview:iv];
    }
    mScrollView.contentSize=CGSizeMake(SCREEN_WIDTH*4, 0);
//    [mScrollView scrollRectToVisible:CGRectMake(0, 0, mScrollView.frame.size.width, mScrollView.frame.size.height) animated:YES];
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    //    CGFloat pageWidth=mFooterScrollView.frame.size.width;
    //    int page=floor((mFooterScrollView.contentOffset.x-pageWidth/2)/pageWidth)+1;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}

@end

//
//  HomeInfoViewController.m
//  Parking
//
//  Created by xujunwu on 15/9/28.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import "HomeInfoViewController.h"

@interface HomeInfoViewController ()<HomeInfoViewDelegate>
{
    HomeInfoView    *infoView;
}
@end

@implementation HomeInfoViewController
@synthesize infoDict,delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (infoView==nil) {
        infoView=[[HomeInfoView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100) delegate:self];
        infoView.infoDict=self.infoDict;
        [self.view addSubview:infoView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refresh
{
    [infoView setInfoDict:self.infoDict];
}

-(void)onHomeInfoViewClicked:(HomeInfoView *)aInfoView type:(int)aType
{
    if (nil!=delegate&& [delegate respondsToSelector:@selector(onHomeInfoViewClicked:type:)]) {
        [delegate onHomeInfoViewClicked:aInfoView.infoDict type:aType];
    }
}

@end

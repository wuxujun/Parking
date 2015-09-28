//
//  AboutViewController.m
//  Parking
//
//  Created by xujunwu on 15/8/31.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "AboutViewController.h"
#import "UIViewController+NavigationBarButton.h"

@implementation AboutViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setCenterTitle:@"关于我们"];
    
    UIImageView  *img=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"splash"]];
    [img setFrame:self.view.bounds];
    [img setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [img setContentMode:UIViewContentModeScaleToFill];
    [self.view addSubview:img];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

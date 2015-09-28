//
//  CustNavigationController.m
//  Parking
//
//  Created by xujunwu on 15/8/30.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "CustNavigationController.h"
#import "MenuViewController.h"
#import "UIViewController+REFrostedViewController.h"

@interface CustNavigationController ()

@property(strong,readwrite,nonatomic)MenuViewController* menuViewController;

@end

@implementation CustNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureRecognized:)]];
    
}
- (void)showMenu
{
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    
    // Present the view controller
    //
    [self.frostedViewController presentMenuViewController];
}

#pragma mark -
#pragma mark Gesture recognizer

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    // Dismiss keyboard (optional)
    //
    CGPoint curPoint = [sender locationInView:self.view];
    CGRect bounds=self.view.frame;
    if (curPoint.x<45)
    {
        [self.view endEditing:YES];
        [self.frostedViewController.view endEditing:YES];
        
        // Present the view controller
        //
        [self.frostedViewController panGestureRecognized:sender];
    }
}

@end

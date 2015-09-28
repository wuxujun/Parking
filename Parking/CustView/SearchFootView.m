//
//  SearchFootView.m
//  Parking
//
//  Created by xujunwu on 15/9/16.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "SearchFootView.h"
#import <QuartzCore/QuartzCore.h>
@implementation SearchFootView


-(id)initWithFrame:(CGRect)frame delegate:(id)aDelegate
{
    self=[super initWithFrame:frame];
    if (self) {
        delegate=aDelegate;
        [self initializeFields];
    }
    return self;
}

-(void)initializeFields
{
    contentView=[[UIView alloc]init];
    [contentView setBackgroundColor:DEFAULT_VIEW_BACKGROUND_COLOR];
    [contentView.layer setBorderWidth:0.3f];
    [contentView.layer setBorderColor:[DEFAULT_LINE_COLOR CGColor]];
    [contentView.layer setMasksToBounds:YES];
    [contentView.layer setCornerRadius:4.0f];
    [contentView.layer setOpacity:80.0f];
    [contentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];

    clearButton=[[UIButton alloc]init];
    [clearButton setTag:1];
    [clearButton.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [clearButton setTitle:@"清空历史" forState:UIControlStateNormal];
    [clearButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [clearButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:clearButton];
    
    [self addSubview:contentView];
    [self reAdjustLayout];

}

-(IBAction)onButton:(id)sender
{
    if ([delegate respondsToSelector:@selector(onSearchFootViewClicked:)]) {
        [delegate onSearchFootViewClicked:self ];
    }
}
-(void)rotate:(UIInterfaceOrientation)interfaceOrientation animation:(BOOL)animation
{
    currrentInterfaceOrientation=interfaceOrientation;
    [self reAdjustLayout];
}

-(void)reAdjustLayout
{
    [contentView setFrame:CGRectMake(5, 0, self.frame.size.width-10, self.frame.size.height)];
    CGSize contentViewArea=CGSizeMake(contentView.frame.size.width, contentView.frame.size.height);
    [clearButton setFrame:CGRectMake(0,0, contentViewArea.width, contentViewArea.height)];
   
}
@end

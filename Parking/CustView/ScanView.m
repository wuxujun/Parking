//
//  ScanView.m
//  Woicar
//
//  Created by xujun wu on 13-9-5.
//  Copyright (c) 2013年 xujun wu. All rights reserved.
//

#import "ScanView.h"

@implementation ScanView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initializedFields];
    }
    return self;
}

-(void)initializedFields
{
    contentView=[[UIView alloc]init];
    
    [contentView setBackgroundColor:[UIColor clearColor]];
    [contentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    
    leftView=[[UIView alloc]init];
    [leftView setBackgroundColor:[UIColor blackColor]];
    [leftView setAlpha:0.5];
    [contentView addSubview:leftView];
    
    topView=[[UIView alloc]init];
    [topView setBackgroundColor:[UIColor blackColor]];
    [topView setAlpha:0.5];
    [contentView addSubview:topView];
    
    rightView=[[UIView alloc]init];
    [rightView setBackgroundColor:[UIColor blackColor]];
    [rightView setAlpha:0.5];
    [contentView addSubview:rightView];
    
    bottomView=[[UIView alloc]init];
    [bottomView setBackgroundColor:[UIColor blackColor]];
    [bottomView setAlpha:0.5];
    [contentView addSubview:bottomView];
    
    titleLabel=[[UILabel alloc]init];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setText:@"将二维码放入框内,即可自动扫描"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [bottomView addSubview:titleLabel];

    topLine=[[UIView alloc]init];
    [topLine setBackgroundColor:[UIColor whiteColor]];
    [contentView addSubview:topLine];
    
    leftLine=[[UIView alloc]init];
    [leftLine setBackgroundColor:[UIColor whiteColor]];
    [contentView addSubview:leftLine];
    
    rightLine=[[UIView alloc]init];
    [rightLine setBackgroundColor:[UIColor whiteColor]];
    [contentView addSubview:rightLine];
    
    bottomLine=[[UIView alloc]init];
    [bottomLine setBackgroundColor:[UIColor whiteColor]];
    [contentView addSubview:bottomLine];
    
    line1=[[UIView alloc]init];
    [line1 setBackgroundColor:[UIColor greenColor]];
    [contentView addSubview:line1];
    
    line2=[[UIView alloc]init];
    [line2 setBackgroundColor:[UIColor greenColor]];
    [contentView addSubview:line2];
    
    line3=[[UIView alloc]init];
    [line3 setBackgroundColor:[UIColor greenColor]];
    [contentView addSubview:line3];
    
    line4=[[UIView alloc]init];
    [line4 setBackgroundColor:[UIColor greenColor]];
    [contentView addSubview:line4];
    
    line5=[[UIView alloc]init];
    [line5 setBackgroundColor:[UIColor greenColor]];
    [contentView addSubview:line5];
    
    line6=[[UIView alloc]init];
    [line6 setBackgroundColor:[UIColor greenColor]];
    [contentView addSubview:line6];
    
    line7=[[UIView alloc]init];
    [line7 setBackgroundColor:[UIColor greenColor]];
    [contentView addSubview:line7];
    
    line8=[[UIView alloc]init];
    [line8 setBackgroundColor:[UIColor greenColor]];
    [contentView addSubview:line8];
    
    [self addSubview:contentView];
    [self reAdjustLayout];
}

-(void)rotate:(UIInterfaceOrientation)interfaceOrientation animation:(BOOL)animation
{
    currrentInterfaceOrientation=interfaceOrientation;
    [self reAdjustLayout];
}

-(void)reAdjustLayout
{
    [contentView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    CGSize contentViewArea=CGSizeMake(contentView.frame.size.width, contentView.frame.size.height);
    [topView setFrame:CGRectMake(0, 0, contentViewArea.width, (contentViewArea.height-(contentViewArea.width-100))/2)];
    
    [leftView setFrame:CGRectMake(0, (contentViewArea.height-(contentViewArea.width-100))/2, 50, contentViewArea.width-100)];
    [rightView setFrame:CGRectMake(contentViewArea.width-50, (contentViewArea.height-(contentViewArea.width-100))/2, 50, contentViewArea.width-100)];
    
    [bottomView setFrame:CGRectMake(0, contentViewArea.height-(contentViewArea.height-(contentViewArea.width-100))/2, contentViewArea.width, (contentViewArea.height-(contentViewArea.width-100))/2)];
    [titleLabel setFrame:CGRectMake(0, 20, contentViewArea.width, 30)];

    [topLine setFrame:CGRectMake(leftView.frame.size.width, topView.frame.size.height, contentViewArea.width-100, 1)];
    [leftLine setFrame:CGRectMake(leftView.frame.size.width, topView.frame.size.height, 1,contentViewArea.width-100)];
    [rightLine setFrame:CGRectMake(leftView.frame.size.width+(contentViewArea.width-100),topView.frame.size.height,1, contentViewArea.width-100)];
    [bottomLine setFrame:CGRectMake(leftView.frame.size.width, topView.frame.size.height+(contentViewArea.width-100), contentViewArea.width-100, 1)];
    
    [line1 setFrame:CGRectMake(leftView.frame.size.width, topView.frame.size.height,4, 20)];
    [line2 setFrame:CGRectMake(leftView.frame.size.width, topView.frame.size.height,20, 4)];
    
    [line3 setFrame:CGRectMake(leftView.frame.size.width+(contentViewArea.width-100)-19, topView.frame.size.height,20, 4)];
    [line4 setFrame:CGRectMake(leftView.frame.size.width+(contentViewArea.width-100)-3, topView.frame.size.height,4, 20)];
    
    [line5 setFrame:CGRectMake(leftView.frame.size.width+(contentViewArea.width-100)-3, topView.frame.size.height+(contentViewArea.width-100)-19,4, 20)];
    [line6 setFrame:CGRectMake(leftView.frame.size.width+(contentViewArea.width-100)-19, topView.frame.size.height+(contentViewArea.width-100)-3,20, 4)];
    
    [line7 setFrame:CGRectMake(leftView.frame.size.width, topView.frame.size.height+(contentViewArea.width-100)-3,20, 4)];
    [line8 setFrame:CGRectMake(leftView.frame.size.width, topView.frame.size.height+(contentViewArea.width-100)-19,4, 20)];
    
    
    
    
}


@end

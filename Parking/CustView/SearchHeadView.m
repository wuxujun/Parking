//
//  SearchHeadView.m
//  Parking
//
//  Created by xujunwu on 15/8/31.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "SearchHeadView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SearchHeadView
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
    [contentView setBackgroundColor:[UIColor clearColor]];
    [contentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    
    
    parkingButton=[[UIButton alloc]init];
    [parkingButton setTag:1];
    [parkingButton.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
//    [parkingButton.layer setBorderWidth:0.5f];
//    [parkingButton.layer setBorderColor:[[UIColor grayColor] CGColor]];
//    [parkingButton.layer setMasksToBounds:YES];
//    [parkingButton.layer setCornerRadius:4.0f];
    [parkingButton setTitle:@"停车场" forState:UIControlStateNormal];
    [parkingButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [parkingButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [parkingButton addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:parkingButton];
    
    busButton=[[UIButton alloc]init];
    [busButton setTag:2];
    [busButton.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
//    [busButton.layer setBorderWidth:0.5f];
//    [busButton.layer setBorderColor:[[UIColor grayColor] CGColor]];
//    [busButton.layer setMasksToBounds:YES];
//    [busButton.layer setCornerRadius:4.0f];
    [busButton setTitle:@"公交站" forState:UIControlStateNormal];
    [busButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [busButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [busButton addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:busButton];
    
    bicycleButton=[[UIButton alloc]init];
    [bicycleButton setTag:3];
    [bicycleButton.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
//    [bicycleButton.layer setBorderWidth:0.5f];
//    [bicycleButton.layer setBorderColor:[[UIColor grayColor] CGColor]];
//    [bicycleButton.layer setMasksToBounds:YES];
//    [bicycleButton.layer setCornerRadius:4.0f];
    [bicycleButton setTitle:@"公共自行车" forState:UIControlStateNormal];
    [bicycleButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [bicycleButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [bicycleButton addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:bicycleButton];
    
    
    keyButton1=[[UIButton alloc]init];
    [keyButton1 setTag:11];
    [keyButton1.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
//    [keyButton1.layer setBorderWidth:0.5f];
//    [keyButton1.layer setBorderColor:[[UIColor grayColor] CGColor]];
//    [keyButton1.layer setMasksToBounds:YES];
//    [keyButton1.layer setCornerRadius:4.0f];
    [keyButton1 setTitle:@"美食" forState:UIControlStateNormal];
    [keyButton1 setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [keyButton1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [keyButton1 addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:keyButton1];
    
    keyButton2=[[UIButton alloc]init];
    [keyButton2 setTag:12];
    [keyButton2.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
//    [keyButton2.layer setBorderWidth:0.5f];
//    [keyButton2.layer setBorderColor:[[UIColor grayColor] CGColor]];
//    [keyButton2.layer setMasksToBounds:YES];
//    [keyButton2.layer setCornerRadius:4.0f];
    [keyButton2 setTitle:@"景点" forState:UIControlStateNormal];
    [keyButton2 setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [keyButton2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [keyButton2 addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:keyButton2];
    
    keyButton3=[[UIButton alloc]init];
    [keyButton3 setTag:13];
    [keyButton3.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
//    [keyButton3.layer setBorderWidth:0.5f];
//    [keyButton3.layer setBorderColor:[[UIColor grayColor] CGColor]];
//    [keyButton3.layer setMasksToBounds:YES];
//    [keyButton3.layer setCornerRadius:4.0f];
    [keyButton3 setTitle:@"酒店" forState:UIControlStateNormal];
    [keyButton3 setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [keyButton3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [keyButton3 addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:keyButton3];
    
    keyButton4=[[UIButton alloc]init];
    [keyButton4 setTag:14];
    [keyButton4.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
//    [keyButton4.layer setBorderWidth:0.5f];
//    [keyButton4.layer setBorderColor:[[UIColor grayColor] CGColor]];
//    [keyButton4.layer setMasksToBounds:YES];
//    [keyButton4.layer setCornerRadius:4.0f];
    [keyButton4 setTitle:@"火车站" forState:UIControlStateNormal];
    [keyButton4 setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [keyButton4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [keyButton4 addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:keyButton4];
    
    keyButton5=[[UIButton alloc]init];
    [keyButton5 setTag:15];
    [keyButton5.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
//    [keyButton5.layer setBorderWidth:0.5f];
//    [keyButton5.layer setBorderColor:[[UIColor grayColor] CGColor]];
//    [keyButton5.layer setMasksToBounds:YES];
//    [keyButton5.layer setCornerRadius:4.0f];
    [keyButton5 setTitle:@"银行" forState:UIControlStateNormal];
    [keyButton5 setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [keyButton5 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [keyButton5 addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:keyButton5];
    
    keyButton6=[[UIButton alloc]init];
    [keyButton6 setTag:16];
    [keyButton6.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
//    [keyButton6.layer setBorderWidth:0.5f];
//    [keyButton6.layer setBorderColor:[[UIColor grayColor] CGColor]];
//    [keyButton6.layer setMasksToBounds:YES];
//    [keyButton6.layer setCornerRadius:4.0f];
    [keyButton6 setTitle:@"汽车站" forState:UIControlStateNormal];
    [keyButton6 setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [keyButton6 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [keyButton6 addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:keyButton6];
    
    keyButton7=[[UIButton alloc]init];
    [keyButton7 setTag:17];
    [keyButton7.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
//    [keyButton7.layer setBorderWidth:0.5f];
//    [keyButton7.layer setBorderColor:[[UIColor grayColor] CGColor]];
//    [keyButton7.layer setMasksToBounds:YES];
//    [keyButton7.layer setCornerRadius:4.0f];
    [keyButton7 setTitle:@"加油站" forState:UIControlStateNormal];
    [keyButton7 setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [keyButton7 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [keyButton7 addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:keyButton7];
    
    keyButton8=[[UIButton alloc]init];
    [keyButton8 setTag:18];
    [keyButton8.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
//    [keyButton8.layer setBorderWidth:0.5f];
//    [keyButton8.layer setBorderColor:[[UIColor grayColor] CGColor]];
//    [keyButton8.layer setMasksToBounds:YES];
//    [keyButton8.layer setCornerRadius:4.0f];
    [keyButton8 setTitle:@"更多" forState:UIControlStateNormal];
    [keyButton8 setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [keyButton8 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [keyButton8 addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:keyButton8];
    
    lineView=[[UIImageView alloc]init];
    [lineView setBackgroundColor:DEFAULT_LINE_COLOR];
    [contentView addSubview:lineView];
    
    lineView1=[[UIImageView alloc]init];
    [lineView1 setBackgroundColor:DEFAULT_LINE_COLOR];
    [contentView addSubview:lineView1];
    lineView2=[[UIImageView alloc]init];
    [lineView2 setBackgroundColor:DEFAULT_LINE_COLOR];
    [contentView addSubview:lineView2];
    lineView3=[[UIImageView alloc]init];
    [lineView3 setBackgroundColor:DEFAULT_LINE_COLOR];
    [contentView addSubview:lineView3];
    lineView4=[[UIImageView alloc]init];
    [lineView4 setBackgroundColor:DEFAULT_LINE_COLOR];
    [contentView addSubview:lineView4];
    lineView5=[[UIImageView alloc]init];
    [lineView5 setBackgroundColor:DEFAULT_LINE_COLOR];
    [contentView addSubview:lineView5];
    lineView6=[[UIImageView alloc]init];
    [lineView6 setBackgroundColor:DEFAULT_LINE_COLOR];
    [contentView addSubview:lineView6];
    lineView7=[[UIImageView alloc]init];
    [lineView7 setBackgroundColor:DEFAULT_LINE_COLOR];
    [contentView addSubview:lineView7];
    lineView8=[[UIImageView alloc]init];
    [lineView8 setBackgroundColor:DEFAULT_LINE_COLOR];
    [contentView addSubview:lineView8];
    
    [self addSubview:contentView];
    [self reAdjustLayout];
}

-(IBAction)onButton:(id)sender
{
    UIButton* btn=(UIButton*)sender;
    if ([delegate respondsToSelector:@selector(onSearchHeadViewClicked:)]) {
        [delegate onSearchHeadViewClicked:btn.titleLabel.text];
    }
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
    float w=(contentViewArea.width-40)/3;
    [parkingButton setFrame:CGRectMake(10, 5, w, 32)];
    [busButton setFrame:CGRectMake(20+w, 5, w, 32)];
    [bicycleButton setFrame:CGRectMake(30+w*2, 5, w, 32)];
    

    w=(contentViewArea.width-50)/4;
    [keyButton1 setFrame:CGRectMake(10, 42, w, 32)];
    [keyButton2 setFrame:CGRectMake(20+w, 42, w, 32)];
    [keyButton3 setFrame:CGRectMake(30+w*2, 42,w, 32)];
    [keyButton4 setFrame:CGRectMake(40+w*3, 42,w, 32)];
    
    [keyButton5 setFrame:CGRectMake(10, 84, w, 32)];
    [keyButton6 setFrame:CGRectMake(20+w, 84, w, 32)];
    [keyButton7 setFrame:CGRectMake(30+w*2, 84,w, 32)];
    [keyButton8 setFrame:CGRectMake(40+w*3, 84,w, 32)];
    [lineView setFrame:CGRectMake(0, contentViewArea.height-1, contentViewArea.width, 0.5)];
    
    [lineView1 setFrame:CGRectMake(0, 40, contentViewArea.width, 0.5)];
    [lineView2 setFrame:CGRectMake(0, 80, contentViewArea.width, 0.5)];
    
    [lineView3 setFrame:CGRectMake(15+w, 42, 0.5, 32)];
    [lineView4 setFrame:CGRectMake(25+w*2, 42, 0.5, 32)];
    [lineView5 setFrame:CGRectMake(45+w*3, 42, 0.5, 32)];
    
    [lineView6 setFrame:CGRectMake(15+w, 84, 0.5, 32)];
    [lineView7 setFrame:CGRectMake(25+w*2,84, 0.5, 32)];
    [lineView8 setFrame:CGRectMake(45+w*3, 84, 0.5, 32)];
    
}

@end

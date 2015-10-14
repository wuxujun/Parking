//
//  BusViewCell.m
//  Parking
//
//  Created by xujunwu on 15/9/16.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "BusViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation BusViewCell

-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        [self initializeFields];
    }
    return self;
}

-(void)initializeFields
{
    contentView=[[UIView alloc]init];
    [contentView setBackgroundColor:DEFAULT_LINE_COLOR];
    [contentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [contentView.layer setCornerRadius:4.0f];
    [contentView.layer setMasksToBounds:YES];
    
    titleLabel=[[UILabel alloc]init];
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    titleLabel.textColor = DEFAULT_FONT_COLOR;
    [contentView addSubview:titleLabel];
    
    startTime=[[UILabel alloc]init];
    startTime.textColor=DEFAULT_FONT_COLOR;
    [startTime setFont:[UIFont systemFontOfSize:12.0f]];
    [contentView addSubview:startTime];
    
    endTime=[[UILabel alloc]init];
    endTime.textColor=DEFAULT_FONT_COLOR;
    endTime.font=[UIFont systemFontOfSize:12.0f];
    [contentView addSubview:endTime];
    
    startIV=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"default_path_bustime_start_normal"]];
    [contentView addSubview:startIV];
    
    endIV=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"default_path_bustime_end_normal"]];
    [contentView addSubview:endIV];
    
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
    [contentView setFrame:CGRectMake(5, 2, self.frame.size.width-10, self.frame.size.height-4)];
    
    CGSize contentViewArea=CGSizeMake(contentView.frame.size.width, contentView.frame.size.height);
    [titleLabel setFrame:CGRectMake(10, 5, contentViewArea.width-80, 30)];
    [startTime setFrame:CGRectMake(contentViewArea.width-80, (contentViewArea.height-20)/2, 40, 20)];
    [endTime setFrame:CGRectMake(contentViewArea.width-30, (contentViewArea.height-20)/2, 40, 20)];
    [startIV setFrame:CGRectMake(contentViewArea.width-100, (contentViewArea.height-18)/2, 18, 18)];
    [endIV setFrame:CGRectMake(contentViewArea.width-50, (contentViewArea.height-18)/2, 18, 18)];
   
}

-(void)setInfoDict:(NSDictionary *)aInfoDict
{
    _infoDict=aInfoDict;
    if ([self.infoDict objectForKey:@"startName"]) {
        [titleLabel setText:[NSString stringWithFormat:@"%@->%@",[self.infoDict objectForKey:@"startName"],[self.infoDict objectForKey:@"endName"]]];
    }
    
    if ([self.infoDict objectForKey:@"startTime"]) {
        [startTime setText:[NSString stringWithFormat:@"%@",[self.infoDict objectForKey:@"startTime"]]];
    }
    if ([self.infoDict objectForKey:@"endTime"]) {
        [endTime setText:[NSString stringWithFormat:@"%@",[self.infoDict objectForKey:@"endTime"]]];
    }
}

@end

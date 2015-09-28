//
//  UserInfoView.m
//  WBMuster
//
//  Created by xujun wu on 12-11-6.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import "UserInfoView.h"
#import <BaseAppArc/UIImageView+WebCache.h>

@implementation UserInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initializeFields];
    }
    return self;
}

-(void)initializeFields
{
    contentView=[[UIView alloc]init];
    [contentView setBackgroundColor:[UIColor clearColor]];
    contentView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    imgView=[[UIImageView alloc]init];
    [imgView setImage:[UIImage imageNamed:@"person"]];
//    [contentView addSubview:imgView];
    
    nameLabel=[[UILabel alloc]init];
    [nameLabel setBackgroundColor:[UIColor clearColor]];
    [nameLabel setFont:[UIFont fontWithName:@"Helvetica" size:16.0f]];
    [nameLabel setTextColor:[UIColor blackColor]];
//    [contentView addSubview:nameLabel];
    
    totalLabel=[[UILabel alloc]init];
    [totalLabel setBackgroundColor:[UIColor clearColor]];
    [totalLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [totalLabel setTextColor:[UIColor whiteColor]];
    [contentView addSubview:totalLabel];
    
    spaceLabel=[[UILabel alloc]init];
    [spaceLabel setBackgroundColor:[UIColor clearColor]];
    [spaceLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [spaceLabel setTextColor:[UIColor whiteColor]];
    [contentView addSubview:spaceLabel];
    
    [self addSubview:contentView];
    
    [self reAdjustLayout];
}

-(void)setName:(NSString *)name
{
    [nameLabel setText:[NSString stringWithFormat:@"姓名: %@",name]];
    [self setNeedsDisplay];
}

-(void)setImgUrl:(NSString *)imgUrl
{
    [imgView setImageWithURL:[NSURL URLWithString:imgUrl]];
    [self setNeedsDisplay];
}

-(void)setTotal:(NSString *)total
{
    [totalLabel setText:[NSString stringWithFormat:@"总计容量: %@",total]];
    [self setNeedsDisplay];
}

-(void)setSpace:(NSString *)space
{
    [spaceLabel setText:[NSString stringWithFormat:@"剩余容量: %@",space]];
    [self setNeedsDisplay];
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
//    [imgView setFrame:CGRectMake(10, 10, 100, 100)];
//    [nameLabel setFrame:CGRectMake(120, 15, contentViewArea.width-130, 25)];
    [totalLabel setFrame:CGRectMake(20, 50, contentViewArea.width, 30)];
    [spaceLabel setFrame:CGRectMake(20, 70, contentViewArea.width, 30)];
}

@end

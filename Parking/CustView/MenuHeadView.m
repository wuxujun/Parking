//
//  MenuHeadView.m
//  Parking
//
//  Created by xujunwu on 15/8/31.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "MenuHeadView.h"
#import "HCurrentUserContext.h"

@implementation MenuHeadView

-(id)initWithFrame:(CGRect)frame delegate:(id)aDelegate
{
    self=[super initWithFrame:frame];
    if (self) {
        delegate=aDelegate;
        [self initializeFields];
        
        UITapGestureRecognizer  *tapRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [tapRecognizer setNumberOfTapsRequired:1];
        [tapRecognizer setNumberOfTouchesRequired:1];
        [self addGestureRecognizer:tapRecognizer];
    }
    return self;
}

-(void)initializeFields
{
    contentView=[[UIView alloc]init];
    [contentView setBackgroundColor:DEFAULT_NAVIGATION_BACKGROUND_COLOR];
    [contentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    
    
    avatarIV=[[UIImageView alloc] init];
    avatarIV.image = [UIImage imageNamed:@"default_account_userphoto_default"];
    [contentView addSubview:avatarIV];
    
    nickLabel=[[UILabel alloc]init];
    
    nickLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
    nickLabel.backgroundColor = [UIColor clearColor];
    [nickLabel setText:@"未登录"];
    nickLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    //    userNickLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [contentView addSubview:nickLabel];
    
    payIV=[[UIImageView alloc] init];
    [payIV setImage:[UIImage imageNamed:@"tab_menu_money"]];
    [contentView addSubview:payIV];
    
    payButton=[[UIButton alloc]init];
    [payButton setTag:1];
    [payButton setTitle:@"支付" forState:UIControlStateNormal];
    [payButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [payButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [payButton addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:payButton];
    
    serverIV=[[UIImageView alloc] init];
    [serverIV setImage:[UIImage imageNamed:@"tab_menu_service"]];
    [contentView addSubview:serverIV];
    
    serverButton=[[UIButton alloc]init];
    [serverButton setTag:2];
    [serverButton setTitle:@"服务" forState:UIControlStateNormal];
    [serverButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [serverButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [serverButton addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:serverButton];
    
    msgIV=[[UIImageView alloc] init];
    [msgIV setImage:[UIImage imageNamed:@"tab_menu_notice"]];
    [contentView addSubview:msgIV];
    
    msgButton=[[UIButton alloc]init];
    [msgButton setTag:3];
    [msgButton setTitle:@"消息中心" forState:UIControlStateNormal];
    [msgButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [msgButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [msgButton addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:msgButton];
    
    
    [self addSubview:contentView];
    [self reAdjustLayout];
}

-(void)handleSingleTap:(UITapGestureRecognizer*)recognizer
{
    if ([delegate respondsToSelector:@selector(onMenuHeadViewClicked:)]) {
        [delegate onMenuHeadViewClicked:0];
    }
}

-(IBAction)onButton:(id)sender
{
    UIButton* btn=(UIButton*)sender;
    if ([delegate respondsToSelector:@selector(onMenuHeadViewClicked:)]) {
        [delegate onMenuHeadViewClicked:btn.tag];
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
    [avatarIV sizeToFit];
    [avatarIV setFrame:CGRectMake(10, 26,64, 64)];
    [nickLabel setFrame:CGRectMake(100, 50, contentViewArea.width-120, 30)];
    float w=(contentViewArea.width-100)/3;
    
    [payIV setFrame:CGRectMake(10+(w-28)/2, contentViewArea.height-50, 28, 28)];
    [payButton setFrame:CGRectMake(10, contentViewArea.height-34, w, 40)];
    [serverIV setFrame:CGRectMake(10+w+(w-28)/2, contentViewArea.height-50, 28, 28)];
    [serverButton setFrame:CGRectMake(10+w, contentViewArea.height-34, w, 40)];
    [msgIV setFrame:CGRectMake(20+w*2+(w-28)/2, contentViewArea.height-50, 28, 28)];
    [msgButton setFrame:CGRectMake(20+w*2, contentViewArea.height-34,w, 40)];
    
}

-(void)reloadData
{
    HCurrentUserContext* userContext=[HCurrentUserContext sharedInstance];
    if (userContext.uid) {
        [nickLabel setText:userContext.username];
    }else{
        [nickLabel setText:@"未登录"];
    }
}

@end

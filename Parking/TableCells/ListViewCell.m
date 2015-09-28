//
//  ListViewCell.m
//  Parking
//
//  Created by xujunwu on 15/9/6.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "ListViewCell.h"
#import "UserDefaultHelper.h"
#import "StringUtil.h"
#import <AMapNaviKit/MAMapKit.h>


@implementation ListViewCell
@synthesize dataType;

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
    [contentView setBackgroundColor:[UIColor clearColor]];
    [contentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    
    
//    iconIV=[[UIImageView alloc] init];
//    iconIV.image = [UIImage imageNamed:@"person"];
//    [contentView addSubview:iconIV];
    
    titleLabel=[[UILabel alloc]init];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = DEFAULT_FONT_COLOR;
    [titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [contentView addSubview:titleLabel];
    
    distanceLabel=[[UILabel alloc]init];
    distanceLabel.textColor=DEFAULT_FONT_COLOR;
    [distanceLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [distanceLabel setTextAlignment:NSTextAlignmentRight];
    [distanceLabel setText:@"100m"];
    [contentView addSubview:distanceLabel];
    
    addressLabel=[[UILabel alloc]init];
    addressLabel.textColor=DEFAULT_FONT_COLOR;
    addressLabel.font=[UIFont systemFontOfSize:12.0f];
    [addressLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [addressLabel setNumberOfLines:0];
    [addressLabel setText:@"地址:杭州市"];
    [contentView addSubview:addressLabel];
    
    priceLabel=[[UILabel alloc] init];
    priceLabel.textColor=DEFAULT_FONT_COLOR;
    [priceLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [priceLabel setNumberOfLines:0];
    [priceLabel setFont:[UIFont systemFontOfSize:12.0]];
    [priceLabel setText:@"收费信息:未知"];
    [contentView addSubview:priceLabel];
    
    
    lineButton=[[UIButton alloc]init];
    [lineButton setTag:1];
    [lineButton.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [lineButton setTitleColor:DEFAULT_FONT_COLOR forState:UIControlStateNormal];
    [lineButton setTitle:@"路线" forState:UIControlStateNormal];
    [lineButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [lineButton addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:lineButton];
    
    lineIV=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"default_main_toolbaritem_path_normal"]];
    [contentView addSubview:lineIV];
    
    
    naviButton=[[UIButton alloc]init];
    [naviButton setTag:2];
    [naviButton.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [naviButton setTitleColor:DEFAULT_FONT_COLOR forState:UIControlStateNormal];
    [naviButton setTitle:@"导航" forState:UIControlStateNormal];
    [naviButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [naviButton addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:naviButton];
    
    naviIV=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"default_main_toolbaritem_navi_normal"]];
    [contentView addSubview:naviIV];
    
    
    spIV=[[UIImageView alloc]init];
    [spIV setBackgroundColor:DEFAULT_FONT_COLOR];
    [contentView addSubview:spIV];
    
    [self addSubview:contentView];
    [self reAdjustLayout];
}


-(void)handleSingleTap:(UITapGestureRecognizer*)recognizer
{
    if ([delegate respondsToSelector:@selector(onListViewCellClicked:forIndex:)]) {
        [delegate onListViewCellClicked:self forIndex:0];
    }
}

-(IBAction)onButton:(id)sender
{
    UIButton* btn=(UIButton*)sender;
    if ([delegate respondsToSelector:@selector(onListViewCellClicked:forIndex:)]) {
        [delegate onListViewCellClicked:self forIndex:btn.tag];
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
//    [iconIV sizeToFit];
//    [iconIV setFrame:CGRectMake(10, 5,100, 80)];
    [spIV setFrame:CGRectMake(contentViewArea.width/2, contentViewArea.height-25, 0.5f, 15.0f)];
    
    [titleLabel setFrame:CGRectMake(10, 5, contentViewArea.width-80, 30)];
    [addressLabel setFrame:CGRectMake(10, 30, contentViewArea.width-120, 20)];
    [priceLabel setFrame:CGRectMake(10, 50, contentViewArea.width-130, 20)];
    [distanceLabel setFrame:CGRectMake(contentViewArea.width-120, 5, 100, 30)];
    
    float w=(contentViewArea.width-20)/2;
    [lineButton setFrame:CGRectMake(10, contentViewArea.height-30, w, 30)];
    [lineIV setFrame:CGRectMake(50, contentViewArea.height-24, 18, 18)];
    [naviButton setFrame:CGRectMake(10+w, contentViewArea.height-30, w, 30)];
    [naviIV setFrame:CGRectMake(50+w, contentViewArea.height-24, 18, 18)];
}

-(void)setInfoDict:(NSDictionary *)aInfoDict
{
    _infoDict=aInfoDict;
    if ([self.infoDict objectForKey:@"title"]) {
        [titleLabel setText:[self.infoDict objectForKey:@"title"]];
    }
    int dType=[[self.infoDict objectForKey:@"dataType"] intValue];
    
    if (self.dataType==3) {
        [priceLabel setHidden:YES];
        if ([self.infoDict objectForKey:@"address"]) {
            [addressLabel setText:[NSString stringWithFormat:@"%@",[self.infoDict objectForKey:@"address"]]];
        }
    }else{
        if ([self.infoDict objectForKey:@"address"]) {
            [addressLabel setText:[NSString stringWithFormat:@"地址:%@",[self.infoDict objectForKey:@"address"]]];
        }
        if ([self.infoDict objectForKey:@"price"]) {
            [priceLabel setText:[NSString stringWithFormat:@"收费信息:%@",[self.infoDict objectForKey:@"price"]]];
        }
    }
    int sourceType=[[self.infoDict objectForKey:@"sourceType"] intValue];
    if (sourceType==1) {
        MAMapPoint point1 = MAMapPointForCoordinate(CLLocationCoordinate2DMake([[UserDefaultHelper objectForKey:CONF_CURRENT_TARGET_LATITUDE] floatValue],[[UserDefaultHelper objectForKey:CONF_CURRENT_TARGET_LONGITUDE] floatValue]));
        MAMapPoint point2 = MAMapPointForCoordinate(CLLocationCoordinate2DMake([[self.infoDict objectForKey:@"latitude"] floatValue],[[self.infoDict objectForKey:@"longitude"] floatValue]));
        //2.计算距离
        CLLocationDistance distance = MAMetersBetweenMapPoints(point1,point2);
        [distanceLabel setText:[NSString stringWithFormat:@"距离:%@",[NSString caleDistance:distance]]];
        
    }else{
        if ([self.infoDict objectForKey:@"distance"]) {
            [distanceLabel setText:[NSString stringWithFormat:@"距离:%@",[NSString caleDistance:[[self.infoDict objectForKey:@"distance"]integerValue]]]];
        }
    }
    if(sourceType==1&&dType==2){
        [priceLabel setHidden:YES];
    }
    if(sourceType==0){
        [priceLabel setHidden:YES];
    }
}

@end

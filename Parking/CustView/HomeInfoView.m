//
//  HomeInfoView.m
//  Parking
//
//  Created by xujunwu on 15/8/31.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "HomeInfoView.h"
#import <QuartzCore/QuartzCore.h>
#import "StringUtil.h"
#import "UserDefaultHelper.h"
#import <AMapNaviKit/MAMapKit.h>

@implementation HomeInfoView
@synthesize infoDict;

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
    
    
    titleLabel=[[UILabel alloc]init];
    [titleLabel setText:@"1.标题"];
    [titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [contentView addSubview:titleLabel];

    
    addressLabel=[[UILabel alloc]init];
    [addressLabel setText:@"杭州市"];
    [addressLabel setHidden:YES];
    [addressLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [contentView addSubview:addressLabel];

    numsLabel=[[UILabel alloc]init];
    [numsLabel setText:@"车位:5/20"];
    [numsLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [contentView addSubview:numsLabel];
    
    
    priceLabel=[[UILabel alloc]init];
    [priceLabel setText:@"价格:5元/小时"];
    [priceLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [contentView addSubview:priceLabel];
    
    
    distanceLabel=[[UILabel alloc]init];
    [distanceLabel setText:@"距离:100米"];
    [distanceLabel setTextAlignment:NSTextAlignmentRight];
    [distanceLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [contentView addSubview:distanceLabel];
    line=[[UIView alloc]init];
    [line setBackgroundColor:DEFAULT_LINE_COLOR];
    [contentView addSubview:line];
    
    nearbyButton=[[UIButton alloc]init];
    [nearbyButton setTag:1];
    [nearbyButton.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [nearbyButton setTitle:@"附近" forState:UIControlStateNormal];
    [nearbyButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [nearbyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [nearbyButton addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:nearbyButton];
    
    
    nearbyIV=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"default_main_toolbaritem_around_normal"]];
    [contentView addSubview:nearbyIV];
    
    line1=[[UIView alloc]init];
    [line1 setBackgroundColor:DEFAULT_LINE_COLOR];
    [contentView addSubview:line1];
    
    lineButton=[[UIButton alloc]init];
    [lineButton setTag:2];
    [lineButton.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [lineButton setTitle:@"线路" forState:UIControlStateNormal];
    [lineButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [lineButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [lineButton addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:lineButton];
    
    
    lineIV=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"default_main_toolbaritem_path_normal"]];
    [contentView addSubview:lineIV];
    
    line2=[[UIView alloc]init];
    [line2 setBackgroundColor:DEFAULT_LINE_COLOR];
    [contentView addSubview:line2];
    
    naviButton=[[UIButton alloc]init];
    [naviButton setTag:3];
    [naviButton.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [naviButton setTitle:@"导航" forState:UIControlStateNormal];
    [naviButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [naviButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [naviButton addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:naviButton];
    
    naviIV=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"default_main_toolbaritem_navi_normal"]];
    [contentView addSubview:naviIV];
    
    
    detailButton=[[UIButton alloc]init];
    [detailButton setTag:11];
    [detailButton.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [detailButton setTitle:@"详情" forState:UIControlStateNormal];
    [detailButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [detailButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [detailButton addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:detailButton];
    
    arrow=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_generalsearch_magicbox_icon_03_normal"]];
    [contentView addSubview:arrow];

    [self addSubview:contentView];
    [self reAdjustLayout];
}

-(IBAction)onButton:(id)sender
{
    UIButton* btn=(UIButton*)sender;
    if ([delegate respondsToSelector:@selector(onHomeInfoViewClicked:type:)]) {
        [delegate onHomeInfoViewClicked:self type:btn.tag];
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
    float w=(contentViewArea.width-40)/3;
    [nearbyButton setFrame:CGRectMake(10,66, w, 32)];
    [nearbyIV setFrame:CGRectMake(20,73, 18, 18)];
    [line1 setFrame:CGRectMake(15+w, 70, 0.5, 20)];
    [lineButton setFrame:CGRectMake(20+w,66, w, 32)];
    [lineIV setFrame:CGRectMake(30+w, 73, 18, 18)];
    [line2 setFrame:CGRectMake(20+w*2, 70, 0.5, 20)];
    [naviButton setFrame:CGRectMake(30+w*2,  66, w, 32)];
    [naviIV setFrame:CGRectMake(40+w*2, 73, 18, 18)];
    [detailButton setFrame:CGRectMake(contentViewArea.width-80, 5, 80, 32)];
    
    [titleLabel setFrame:CGRectMake(10, 5, contentViewArea.width-80, 32)];
    [addressLabel setFrame:CGRectMake(10, 34, contentViewArea.width-100, 26)];
    [numsLabel setFrame:CGRectMake(10, 34, w, 26)];
    [priceLabel setFrame:CGRectMake(20+w, 34, w, 26)];
    [distanceLabel setFrame:CGRectMake(30+w*2, 34, w, 26)];
    [line setFrame:CGRectMake(10, 64, contentViewArea.width-20, 0.4)];
    
    [arrow setFrame:CGRectMake(contentViewArea.width-26, 15, 12, 12)];
}

-(void)setInfoDict:(NSDictionary *)aInfoDict
{
    infoDict=aInfoDict;
//    HLog(@"%@",infoDict);
    if ([infoDict objectForKey:@"title"]) {
        [titleLabel setText:[NSString stringWithFormat:@"%@.%@",[infoDict objectForKey:@"idx"],[infoDict objectForKey:@"title"]]];
    }
    int dataType=[[infoDict objectForKey:@"dataType"] intValue];
    int sourceType=[[infoDict objectForKey:@"sourceType"] intValue];
    if (sourceType==0) {
        [addressLabel setHidden:NO];
        [numsLabel setHidden:YES];
        [priceLabel setHidden:YES];
        if ([infoDict objectForKey:@"address"]) {
            [addressLabel setText:[infoDict objectForKey:@"address"]];
        }
        NSInteger distance=[[infoDict objectForKey:@"distance"] integerValue];
        [distanceLabel setText:[NSString stringWithFormat:@"距离:%@",[NSString caleDistance:distance]]];
    
    }else{
        int freeCount=[[infoDict objectForKey:@"freeCount"] intValue];
        int totalCount=[[infoDict objectForKey:@"totalCount"] intValue];
        
        if (dataType==2) {
            [addressLabel setHidden:YES];
            [numsLabel setHidden:NO];
            [priceLabel setHidden:YES];
            if (freeCount==-1) {
                [numsLabel setText:[NSString stringWithFormat:@"数量:%d个",totalCount]];
            }else{
                [numsLabel setText:[NSString stringWithFormat:@"数量:%d/%d",freeCount,totalCount]];
            }
        }else{
            [addressLabel setHidden:YES];
            [numsLabel setHidden:NO];
            [priceLabel setHidden:NO];
            if (freeCount==-1) {
                [numsLabel setText:[NSString stringWithFormat:@"车位:%d个",totalCount]];
            }else{
                [numsLabel setText:[NSString stringWithFormat:@"车位:%d/%d",freeCount,totalCount]];
            }
            NSString* price=[infoDict objectForKey:@"charge"];
            if (price==(id)[NSNull null]||price.length==0) {
                [priceLabel setText:@"价格:未知"];
            }else if ([price isEqualToString:@"0"]) {
                [priceLabel setText:@"价格:免费"];
            }else if([price isEqualToString:@"1"]&&[infoDict objectForKey:@"chargeDetail"]){
                [priceLabel setText:[NSString stringWithFormat:@"价格:%@",[infoDict objectForKey:@"chargeDetail"]]];
            }else{
                [priceLabel setText:[NSString stringWithFormat:@"价格:%@",[infoDict objectForKey:@"chargeDetail"]]];
            }
        }
        HLog(@"%@    -->%@   =====>   %@  --> %@",[UserDefaultHelper objectForKey:CONF_CURRENT_TARGET_LATITUDE],[UserDefaultHelper objectForKey:CONF_CURRENT_TARGET_LONGITUDE],[infoDict objectForKey:@"latitude"],[infoDict objectForKey:@"longitude"]);
        MAMapPoint point1 = MAMapPointForCoordinate(CLLocationCoordinate2DMake([[UserDefaultHelper objectForKey:CONF_CURRENT_TARGET_LATITUDE] floatValue],[[UserDefaultHelper objectForKey:CONF_CURRENT_TARGET_LONGITUDE] floatValue]));
        MAMapPoint point2 = MAMapPointForCoordinate(CLLocationCoordinate2DMake([[infoDict objectForKey:@"latitude"] floatValue],[[infoDict objectForKey:@"longitude"] floatValue]));
        //2.计算距离
        CLLocationDistance distance = MAMetersBetweenMapPoints(point1,point2);
        [distanceLabel setText:[NSString stringWithFormat:@"距离:%@",[NSString caleDistance:distance]]];
    }

}

@end

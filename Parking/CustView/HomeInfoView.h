//
//  HomeInfoView.h
//  Parking
//
//  Created by xujunwu on 15/8/31.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "UIViewExtention.h"

@protocol HomeInfoViewDelegate;

@interface HomeInfoView : UIViewExtention
{
    UIView                  *contentView;
    
    UILabel                 *titleLabel;
    UILabel                 *addressLabel;
    UILabel                 *numsLabel;
    UILabel                 *priceLabel;
    UILabel                 *distanceLabel;
    
    UIImageView             *nearbyIV;
    UIButton                *nearbyButton;
    UIImageView             *lineIV;
    UIButton                *lineButton;
    UIImageView             *naviIV;
    UIButton                *naviButton;
    UIButton                *detailButton;
    
    
    UIView                  *line;
    UIView                  *line1;
    UIView                  *line2;
    UIImageView             *arrow;
    
    id<HomeInfoViewDelegate>        delegate;
    
}
@property(nonatomic,strong)NSDictionary* infoDict;

-(id)initWithFrame:(CGRect)frame delegate:(id)aDelegate;
-(void)initializeFields;

@end


@protocol HomeInfoViewDelegate <NSObject>

-(void)onHomeInfoViewClicked:(HomeInfoView*)aInfoView type:(int)aType;

@end
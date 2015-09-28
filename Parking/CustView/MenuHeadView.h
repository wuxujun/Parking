//
//  MenuHeadView.h
//  Parking
//
//  Created by xujunwu on 15/8/31.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "UIViewExtention.h"

@protocol MenuHeadViewDelegate;

@interface MenuHeadView : UIViewExtention
{
    
    UIView                  *contentView;
    
    UIImageView             *avatarIV;
    UILabel                 *nickLabel;
    UIImageView             *msgIV;
    UIButton                *msgButton;
    UIImageView             *payIV;
    UIButton                *payButton;
    UIImageView             *serverIV;
    UIButton                *serverButton;
    
    id<MenuHeadViewDelegate>        delegate;
}

-(id)initWithFrame:(CGRect)frame delegate:(id)aDelegate;
-(void)initializeFields;

-(void)reloadData;

@end

@protocol MenuHeadViewDelegate <NSObject>
-(void)onMenuHeadViewClicked:(int)idx;
@end
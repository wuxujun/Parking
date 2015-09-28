//
//  SearchHeadView.h
//  Parking
//
//  Created by xujunwu on 15/8/31.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "UIViewExtention.h"

@protocol SearchHeadViewDelegate;

@interface SearchHeadView : UIViewExtention
{
    
    UIView                  *contentView;
    
    UIButton                *parkingButton;
    UIButton                *busButton;
    UIButton                *bicycleButton;
    
    UIButton                *keyButton1;
    UIButton                *keyButton2;
    UIButton                *keyButton3;
    UIButton                *keyButton4;
    UIButton                *keyButton5;
    UIButton                *keyButton6;
    UIButton                *keyButton7;
    UIButton                *keyButton8;
    
    UIImageView             *lineView;
    
    
    UIImageView             *lineView1;
    UIImageView             *lineView2;
    UIImageView             *lineView3;
    UIImageView             *lineView4;
    UIImageView             *lineView5;
    UIImageView             *lineView6;
    UIImageView             *lineView7;
    UIImageView             *lineView8;
    
    id<SearchHeadViewDelegate>        delegate;
}

-(id)initWithFrame:(CGRect)frame delegate:(id)aDelegate;
-(void)initializeFields;

@end

@protocol SearchHeadViewDelegate <NSObject>

-(void)onSearchHeadViewClicked:(NSString*)keyworkd;
@end
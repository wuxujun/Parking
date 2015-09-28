//
//  SearchFootView.h
//  Parking
//
//  Created by xujunwu on 15/9/16.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "UIViewExtention.h"

@protocol SearchFootViewDelegate;

@interface SearchFootView : UIViewExtention
{
    UIView          *contentView;
    UIButton        *clearButton;
    
    id<SearchFootViewDelegate>      delegate;
}

-(id)initWithFrame:(CGRect)frame delegate:(id)aDelegate;

-(void)initializeFields;

@end

@protocol SearchFootViewDelegate <NSObject>

-(void)onSearchFootViewClicked:(SearchFootView*)view;

@end
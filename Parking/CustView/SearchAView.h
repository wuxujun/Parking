//
//  SearchAView.h
//  Parking
//
//  Created by xujunwu on 15/10/10.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchAViewDelegate;

@interface SearchAView : UIView<UITableViewDataSource,UITableViewDelegate>
{
    id<SearchAViewDelegate>  delegate;
}

-(id)initWithFrame:(CGRect)frame delegate:(id)aDelegate;
- (void)showInView:(UIView *)view;
- (void)dismissMenuPopover;
- (void)layoutUIForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end


@protocol SearchAViewDelegate <NSObject>

-(void)viewSwitch:(SearchAView*)view forIndex:(NSInteger)idx;
-(void)viewChargeSwitch:(SearchAView*)view forIndex:(NSInteger)idx;
-(void)viewTypeSwitch:(SearchAView*)view forIndex:(NSInteger)idx;
-(void)viewStatusSwitch:(SearchAView*)view forIndex:(NSInteger)idx;

@end
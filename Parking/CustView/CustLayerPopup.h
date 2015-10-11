//
//  CustLayerPopup.h
//  Parking
//
//  Created by xujunwu on 15/8/31.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustLayerPopupDelegate;


@interface CustLayerPopup : UIView<UITableViewDelegate,UITableViewDataSource>
{
    id<CustLayerPopupDelegate>  delegate;
}

-(id)initWithFrame:(CGRect)frame delegate:(id)aDelegate;
- (void)showInView:(UIView *)view;
- (void)dismissMenuPopover;
- (void)layoutUIForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end


@protocol CustLayerPopupDelegate <NSObject>

-(void)viewSwitch:(CustLayerPopup*)view forIndex:(NSInteger)idx;
-(void)viewChargeSwitch:(CustLayerPopup*)view forIndex:(NSInteger)idx;
-(void)viewTypeSwitch:(CustLayerPopup*)view forIndex:(NSInteger)idx;
-(void)viewStatusSwitch:(CustLayerPopup*)view forIndex:(NSInteger)idx;

@end

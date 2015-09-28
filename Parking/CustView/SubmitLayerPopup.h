//
//  SubmitLayerPopup.h
//  Parking
//
//  Created by xujunwu on 15/9/18.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HNetworkEngine.h"

@protocol SubmitLayerPopupDelegate;

@interface SubmitLayerPopup : UIView<UITableViewDataSource,UITableViewDelegate>
{
    id<SubmitLayerPopupDelegate>        delegate;
}
@property(nonatomic,strong)HNetworkEngine*  networkEngine;

-(id)initWithFrame:(CGRect)frame delegate:(id)aDelegate;

-(void)showInView:(UIView*)view;
-(void)dismissPopover;

- (void)layoutUIForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end


@protocol SubmitLayerPopupDelegate <NSObject>

-(void)onSubmitContent:(SubmitLayerPopup*)view;

@end
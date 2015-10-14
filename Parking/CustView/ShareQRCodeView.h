//
//  ShareQRCodeView.h
//  Parking
//
//  Created by xujunwu on 15/10/11.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ShareQRCodeViewDelegate;

@interface ShareQRCodeView : UIView<UITableViewDataSource,UITableViewDelegate>
{
    id<ShareQRCodeViewDelegate>  delegate;
}

-(id)initWithFrame:(CGRect)frame delegate:(id)aDelegate;
- (void)showInView:(UIView *)view;
- (void)dismissPopover;
- (void)layoutUIForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end

@protocol ShareQRCodeViewDelegate <NSObject>

-(void)onClickShareItem:(ShareQRCodeView*)view forIndex:(NSInteger)idx;
@end
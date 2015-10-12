//
//  SelectViewPopup.h
//  Parking
//
//  Created by xujunwu on 15/10/12.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HNetworkEngine.h"

@protocol SelectViewPopupDelegate;

@interface SelectViewPopup : UIView<UITableViewDataSource,UITableViewDelegate>
{
    id<SelectViewPopupDelegate>        delegate;
}

-(id)initWithFrame:(CGRect)frame delegate:(id)aDelegate;

-(void)showInView:(UIView*)view;
-(void)dismissPopover;

- (void)layoutUIForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end

@protocol SelectViewPopupDelegate <NSObject>

-(void)onSelectContent:(SelectViewPopup*)view forIndex:(NSInteger)tag;

@end

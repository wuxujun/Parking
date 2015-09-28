//
//  UserInfoView.h
//  WBMuster
//
//  Created by xujun wu on 12-11-6.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaseAppArc/UIViewExtention.h>

@interface UserInfoView : UIViewExtention
{
    UIView          *contentView;
    UIImageView     *imgView;
    UILabel         *nameLabel;
    UILabel         *totalLabel;
    UILabel         *spaceLabel;
}
@property (nonatomic,strong)NSString  *imgUrl;
@property (nonatomic,strong)NSString  *name;
@property (nonatomic,strong)NSString  *total;
@property (nonatomic,strong)NSString  *space;

@end

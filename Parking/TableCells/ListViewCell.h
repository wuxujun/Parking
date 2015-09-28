//
//  ListViewCell.h
//  Parking
//
//  Created by xujunwu on 15/9/6.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "UIViewExtention.h"

@protocol ListViewCellDelegate;

@interface ListViewCell : UIViewExtention
{
    UIView                  *contentView;

    UIImageView             *iconIV;
    UILabel                 *titleLabel;
    UILabel                 *addressLabel;
    UILabel                 *priceLabel;
    UILabel                 *distanceLabel;
    
    UIButton                *lineButton;
    UIImageView             *lineIV;
    UIButton                *naviButton;
    UIImageView             *naviIV;
    UIImageView             *spIV;
    
    id<ListViewCellDelegate>        delegate;
}
@property(nonatomic,assign)int              dataType;
@property(nonatomic,strong)NSDictionary*    infoDict;

-(id)initWithFrame:(CGRect)frame delegate:(id)aDelegate;
-(void)initializeFields;

@end

@protocol ListViewCellDelegate <NSObject>
-(void)onListViewCellClicked:(ListViewCell*)view forIndex:(int)idx;
@end
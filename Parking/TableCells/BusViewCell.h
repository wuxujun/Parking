//
//  BusViewCell.h
//  Parking
//
//  Created by xujunwu on 15/9/16.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "UIViewExtention.h"

@interface BusViewCell : UIViewExtention
{
    UIView                  *contentView;
    
    UILabel                 *titleLabel;
    UILabel                 *startTime;
    UILabel                 *endTime;
    
    UIImageView             *startIV;
    UIImageView             *endIV;
    
}
@property(nonatomic,strong)NSDictionary*    infoDict;

-(id)initWithFrame:(CGRect)frame;
-(void)initializeFields;

@end

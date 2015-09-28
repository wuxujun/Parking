//
//  ScanView.h
//  Woicar
//
//  Created by xujun wu on 13-9-5.
//  Copyright (c) 2013年 xujun wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewExtention.h"

@interface ScanView : UIViewExtention
{
    UIView              *contentView;
    UIView              *topView;
    UIView              *leftView;
    UIView              *rightView;
    UIView              *bottomView;
    
    UILabel             *titleLabel;
    
    UIView              *topLine;
    UIView              *leftLine;
    UIView              *rightLine;
    UIView              *bottomLine;
    
    UIView              *line1;
    UIView              *line2;
    UIView              *line3;
    UIView              *line4;
    UIView              *line5;
    UIView              *line6;
    UIView              *line7;
    UIView              *line8;
}

@end

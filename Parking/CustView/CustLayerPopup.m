//
//  CustLayerPopup.m
//  Parking
//
//  Created by xujunwu on 15/8/31.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "CustLayerPopup.h"
#import "UserDefaultHelper.h"
#import <QuartzCore/QuartzCore.h>

#define RGBA(a, b, c, d) [UIColor colorWithRed:(a / 255.0f) green:(b / 255.0f) blue:(c / 255.0f) alpha:d]

#define MENU_ITEM_HEIGHT        44
#define FONT_SIZE               15
#define CELL_IDENTIGIER         @"MenuPopoverCell"
#define MENU_TABLE_VIEW_FRAME   CGRectMake(0, 0, frame.size.width, frame.size.height)
#define SEPERATOR_LINE_RECT     CGRectMake(10, MENU_ITEM_HEIGHT - 1, self.frame.size.width - 20, 0.5)
#define MENU_POINTER_RECT       CGRectMake(frame.origin.x, frame.origin.y, 23, 11)

#define CONTAINER_BG_COLOR      RGBA(0, 0, 0, 0.1f)

#define ZERO                    0.0f
#define ONE                     1.0f
#define ANIMATION_DURATION      0.5f

#define MENU_POINTER_TAG        1011
#define MENU_TABLE_VIEW_TAG     1012

#define LANDSCAPE_WIDTH_PADDING 50

@interface CustLayerPopup()
{
    UIButton            *parkingBtn;
    UIButton            *bicycleBtn;
    UIButton            *busBtn;
}
@property(nonatomic,strong)UIButton     *containerButton;

@end

@implementation CustLayerPopup
@synthesize containerButton;

- (id)initWithFrame:(CGRect)frame delegate:(id)aDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        delegate=aDelegate;
        
        self.containerButton = [[UIButton alloc] init];
        [self.containerButton setBackgroundColor:CONTAINER_BG_COLOR];
        [self.containerButton addTarget:self action:@selector(dismissMenuPopover) forControlEvents:UIControlEventTouchUpInside];
        [self.containerButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin];
        
        // Adding Menu Options Pointer
//        UIImageView *menuPointerView = [[UIImageView alloc] initWithFrame:MENU_POINTER_RECT];
//        menuPointerView.backgroundColor=DEFAULT_FONT_COLOR;
//        menuPointerView.tag = MENU_POINTER_TAG;
//        [self.containerButton addSubview:menuPointerView];
        
        // Adding menu Items table
        UITableView *menuItemsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    
        menuItemsTableView.dataSource = self;
        menuItemsTableView.delegate = self;
        menuItemsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        menuItemsTableView.scrollEnabled = NO;
        menuItemsTableView.backgroundColor = DEFAULT_VIEW_BACKGROUND_COLOR;
        menuItemsTableView.tag = MENU_TABLE_VIEW_TAG;
        
//        UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Menu_PopOver_BG"]];
//        menuItemsTableView.backgroundView = bgView;
        
        [self addSubview:menuItemsTableView];
        
        [self.containerButton addSubview:self];
    }
    return self;
}


-(IBAction)onButton:(id)sender
{
    UIButton* btn=(UIButton*)sender;
    switch (btn.tag) {
        case 1:{
            [UserDefaultHelper setObject:[NSNumber numberWithInt:1] forKey:CONF_CURRENT_LAYER_TYPE];
            [bicycleBtn setImage:[UIImage imageNamed:@"image_select_no"] forState:UIControlStateNormal];
            [busBtn setImage:[UIImage imageNamed:@"image_select_no"] forState:UIControlStateNormal];
            break;
        }
        case 2:{
            [UserDefaultHelper setObject:[NSNumber numberWithInt:2] forKey:CONF_CURRENT_LAYER_TYPE];
            [busBtn setImage:[UIImage imageNamed:@"image_select_no"] forState:UIControlStateNormal];
            [parkingBtn setImage:[UIImage imageNamed:@"image_select_no"] forState:UIControlStateNormal];
            break;
        }
        case 3:{
            
            [UserDefaultHelper setObject:[NSNumber numberWithInt:3] forKey:CONF_CURRENT_LAYER_TYPE];
            [bicycleBtn setImage:[UIImage imageNamed:@"image_select_no"] forState:UIControlStateNormal];
            [parkingBtn setImage:[UIImage imageNamed:@"image_select_no"] forState:UIControlStateNormal];
            break;
        }
    }
    [btn setImage:[UIImage imageNamed:@"image_select_yes"] forState:UIControlStateNormal];
    if ([delegate respondsToSelector:@selector(viewSwitch:forIndex:)]) {
        [delegate viewSwitch:self forIndex:btn.tag];
    }
}

#pragma mark -
#pragma mark UITableViewDatasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return MENU_ITEM_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
        default:
            return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = CELL_IDENTIGIER;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (indexPath.section==0) {
        int layerType=[[UserDefaultHelper objectForKey:CONF_CURRENT_LAYER_TYPE] intValue];
        
        float width=self.frame.size.width/3.0;
        parkingBtn=[[UIButton alloc]initWithFrame:CGRectMake(10, 5, 32, 32)];
        [parkingBtn setTag:1];
        if (layerType==1) {
            [parkingBtn setImage:[UIImage imageNamed:@"image_select_yes"] forState:UIControlStateNormal];
        }else{
            [parkingBtn setImage:[UIImage imageNamed:@"image_select_no"] forState:UIControlStateNormal];
        }
        [parkingBtn addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:parkingBtn];
        
        UILabel* pLabel=[[UILabel alloc]initWithFrame:CGRectMake(40, 5, width-40, 30)];
        [pLabel setText:@"停车场"];
        [pLabel setFont:[UIFont systemFontOfSize:14.0]];
        [cell addSubview:pLabel];
        
        bicycleBtn=[[UIButton alloc]initWithFrame:CGRectMake(width, 5, 32, 32)];
        [bicycleBtn setTag:2];
        if (layerType==2) {
            [bicycleBtn setImage:[UIImage imageNamed:@"image_select_yes"] forState:UIControlStateNormal];
        }else{
            [bicycleBtn setImage:[UIImage imageNamed:@"image_select_no"] forState:UIControlStateNormal];
        }
        [bicycleBtn addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:bicycleBtn];
        UILabel* bLabel=[[UILabel alloc]initWithFrame:CGRectMake(30+width, 5, width-30, 30)];
        [bLabel setText:@"公共自行车"];
        [bLabel setFont:[UIFont systemFontOfSize:14.0]];
        [cell addSubview:bLabel];
        
        busBtn=[[UIButton alloc]initWithFrame:CGRectMake(10+width*2, 5, 32, 32)];
        [busBtn setTag:3];
        if (layerType==3) {
            [busBtn setImage:[UIImage imageNamed:@"image_select_yes"] forState:UIControlStateNormal];
        }else{
            [busBtn setImage:[UIImage imageNamed:@"image_select_no"] forState:UIControlStateNormal];
        }
        [busBtn addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:busBtn];
        
        
        UILabel* biLabel=[[UILabel alloc]initWithFrame:CGRectMake(40+width*2, 5, width-40, 30)];
        [biLabel setText:@"公交站"];
        [biLabel setFont:[UIFont systemFontOfSize:14.0]];
        [cell addSubview:biLabel];
        
        [self addSeparatorImageToCell:cell];
    }else{
        NSInteger numberOfRows = [tableView numberOfRowsInSection:indexPath.section];
        if( [tableView numberOfRowsInSection:indexPath.section] > ONE && !(indexPath.row == numberOfRows - 1) )
        {
            [self addSeparatorImageToCell:cell];
        }
        cell.textLabel.text = @"停车场状态";
        if (indexPath.row==1) {
            cell.textLabel.text=@"滑动显示停车场";
        }
        [cell.textLabel setFont:[UIFont boldSystemFontOfSize:FONT_SIZE]];
        [cell.textLabel setTextColor:DEFAULT_FONT_COLOR];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        
        UISwitch *sw=[[UISwitch alloc]initWithFrame:CGRectMake(self.frame.size.width-80, 5, 100, 32)];
        [sw setTag:indexPath.row];
        if (indexPath.row==0) {
            [sw setOn:[[[NSUserDefaults standardUserDefaults] objectForKey:CONF_PARKING_STATUS] boolValue]];
        }else{
            [sw setOn:[[[NSUserDefaults standardUserDefaults] objectForKey:CONF_PARKING_MOVE_SHOW] boolValue]];
        }
        [sw addTarget:self action:@selector(switchStatus:) forControlEvents:UIControlEventValueChanged];
        [cell addSubview:sw];
        
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hide];
}

-(IBAction)switchStatus:(id)sender
{
    UISwitch* sw=(UISwitch*)sender;
    if (sw.tag==0) {
        [[NSUserDefaults standardUserDefaults] setBool:sw.isOn forKey:CONF_PARKING_STATUS];
    }else{
        [[NSUserDefaults standardUserDefaults] setBool:sw.isOn forKey:CONF_PARKING_MOVE_SHOW];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}
#pragma mark -
#pragma mark Actions

- (void)dismissMenuPopover
{
    [self hide];
}

- (void)showInView:(UIView *)view
{
    self.containerButton.alpha = ZERO;
    self.containerButton.frame = view.bounds;
    [view addSubview:self.containerButton];
    
    [UIView animateWithDuration:ANIMATION_DURATION
                     animations:^{
                         self.containerButton.alpha = ONE;
                     }
                     completion:^(BOOL finished) {}];
}

- (void)hide
{
    [UIView animateWithDuration:ANIMATION_DURATION
                     animations:^{
                         self.containerButton.alpha = ZERO;
                     }
                     completion:^(BOOL finished) {
                         [self.containerButton removeFromSuperview];
                     }];
}

#pragma mark -
#pragma mark Separator Methods

- (void)addSeparatorImageToCell:(UITableViewCell *)cell
{
    UIImageView *separatorImageView = [[UIImageView alloc] initWithFrame:SEPERATOR_LINE_RECT];
    separatorImageView.backgroundColor=DEFAULT_LINE_COLOR;
    separatorImageView.opaque = YES;
    [cell.contentView addSubview:separatorImageView];
}

#pragma mark -
#pragma mark Orientation Methods

- (void)layoutUIForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    BOOL landscape = (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    
    UIImageView *menuPointerView = (UIImageView *)[self.containerButton viewWithTag:MENU_POINTER_TAG];
    UITableView *menuItemsTableView = (UITableView *)[self.containerButton viewWithTag:MENU_TABLE_VIEW_TAG];
    
    if( landscape )
    {
        menuPointerView.frame = CGRectMake(menuPointerView.frame.origin.x + LANDSCAPE_WIDTH_PADDING, menuPointerView.frame.origin.y, menuPointerView.frame.size.width, menuPointerView.frame.size.height);
        
        menuItemsTableView.frame = CGRectMake(menuItemsTableView.frame.origin.x + LANDSCAPE_WIDTH_PADDING, menuItemsTableView.frame.origin.y, menuItemsTableView.frame.size.width, menuItemsTableView.frame.size.height);
    }
    else
    {
        menuPointerView.frame = CGRectMake(menuPointerView.frame.origin.x - LANDSCAPE_WIDTH_PADDING, menuPointerView.frame.origin.y, menuPointerView.frame.size.width, menuPointerView.frame.size.height);
        
        menuItemsTableView.frame = CGRectMake(menuItemsTableView.frame.origin.x - LANDSCAPE_WIDTH_PADDING, menuItemsTableView.frame.origin.y, menuItemsTableView.frame.size.width, menuItemsTableView.frame.size.height);
    }
}

@end

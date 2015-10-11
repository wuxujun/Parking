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

#define MENU_ITEM_HEIGHT        64
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
    NSMutableArray      *data;
    UITableView         *mTableView;
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
        data=[[NSMutableArray alloc]init];
        
        self.containerButton = [[UIButton alloc] init];
        [self.containerButton setBackgroundColor:CONTAINER_BG_COLOR];
        [self.containerButton addTarget:self action:@selector(dismissMenuPopover) forControlEvents:UIControlEventTouchUpInside];
        [self.containerButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin];
        
        // Adding Menu Options Pointer
//        UIImageView *menuPointerView = [[UIImageView alloc] initWithFrame:MENU_POINTER_RECT];
//        menuPointerView.backgroundColor=DEFAULT_FONT_COLOR;
//        menuPointerView.tag = MENU_POINTER_TAG;
//        [self.containerButton addSubview:menuPointerView];
        
        [self loadData];
        // Adding menu Items table
        mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    
        mTableView.dataSource = self;
        mTableView.delegate = self;
        mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        mTableView.scrollEnabled = NO;
        mTableView.backgroundColor = DEFAULT_VIEW_BACKGROUND_COLOR;
        mTableView.tag = MENU_TABLE_VIEW_TAG;
        
//        UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Menu_PopOver_BG"]];
//        menuItemsTableView.backgroundView = bgView;
        
        [self addSubview:mTableView];
        
        [self.containerButton addSubview:self];
    }
    return self;
}

-(void)loadData
{
    NSString* fileName=@"setting_layer";

    NSData *jsdata = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"json"]];
    @autoreleasepool {
        if (jsdata)
        {
            NSArray *dicArray = [NSJSONSerialization JSONObjectWithData:jsdata options:NSJSONReadingAllowFragments error:nil];
            for (NSDictionary *dic in dicArray)
            {
                [data addObject:dic];
            }
        }
    }
    
}

-(IBAction)onButton:(id)sender
{
    UIButton* btn=(UIButton*)sender;
    switch (btn.tag) {
        case 1:{
            [UserDefaultHelper setObject:@"1" forKey:CONF_CURRENT_LAYER_TYPE];
            break;
        }
        case 2:{
            [UserDefaultHelper setObject:@"2" forKey:CONF_CURRENT_LAYER_TYPE];
            break;
        }
        case 3:{
            
            [UserDefaultHelper setObject:@"3" forKey:CONF_CURRENT_LAYER_TYPE];
            break;
        }
    }
    if ([delegate respondsToSelector:@selector(viewSwitch:forIndex:)]) {
        [delegate viewSwitch:self forIndex:btn.tag];
    }
}

-(IBAction)onTypeButton:(id)sender
{
    UIButton* btn=(UIButton*)sender;
    switch (btn.tag) {
        case 2:
        {
            [UserDefaultHelper setObject:@"道路停车场" forKey:CONF_PARKING_MAP_TYPE];
        }
            break;
        case 3:
        {
            [UserDefaultHelper setObject:@"地面停车场" forKey:CONF_PARKING_MAP_TYPE];
        }
            break;
        case 4:
        {
            [UserDefaultHelper setObject:@"地下停车场" forKey:CONF_PARKING_MAP_TYPE];
            
        }
            break;
        default:
        {
            [UserDefaultHelper setObject:@"0" forKey:CONF_PARKING_MAP_TYPE];
        }
            break;
    }
    [mTableView reloadData];
    if ([delegate respondsToSelector:@selector(viewTypeSwitch:forIndex:)]) {
        [delegate viewTypeSwitch:self forIndex:btn.tag];
    }
}

-(IBAction)onStatusButton:(id)sender
{
    UIButton* btn=(UIButton*)sender;
    switch (btn.tag) {
        case 2:
        {
            [UserDefaultHelper setObject:@"充足" forKey:CONF_PARKING_MAP_STATUS];
        }
            break;
        case 3:
        {
             [UserDefaultHelper setObject:@"较少" forKey:CONF_PARKING_MAP_STATUS];
        }
            break;
        case 4:
        {
             [UserDefaultHelper setObject:@"紧缺" forKey:CONF_PARKING_MAP_STATUS];
            
        }
            break;
        default:
        {
             [UserDefaultHelper setObject:@"0" forKey:CONF_PARKING_MAP_STATUS];
        }
            break;
    }
    [mTableView reloadData];
    if ([delegate respondsToSelector:@selector(viewStatusSwitch:forIndex:)]) {
        [delegate viewStatusSwitch:self forIndex:btn.tag];
    }
}

-(IBAction)onChargeButton:(id)sender
{
    UIButton* btn=(UIButton*)sender;
    switch (btn.tag) {
        case 2:
        {
             [UserDefaultHelper setObject:@"收费" forKey:CONF_PARKING_MAP_CHARGE];
        }
            break;
        case 3:
        {
             [UserDefaultHelper setObject:@"免费" forKey:CONF_PARKING_MAP_CHARGE];
        }
            break;
        default:
        {
             [UserDefaultHelper setObject:@"0" forKey:CONF_PARKING_MAP_CHARGE];
        }
            break;
    }
    [mTableView reloadData];
    if ([delegate respondsToSelector:@selector(viewChargeSwitch:forIndex:)]) {
        [delegate viewChargeSwitch:self forIndex:btn.tag];
    }
}

#pragma mark -
#pragma mark UITableViewDatasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return MENU_ITEM_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
   return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = CELL_IDENTIGIER;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSDictionary* dict=[data objectAtIndex:indexPath.row];
    
    if(indexPath.row==1||indexPath.row==2){
        UILabel* biLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH-40, 26)];
        [biLabel setText:[dict objectForKey:@"title"]];
        [biLabel setFont:[UIFont boldSystemFontOfSize:FONT_SIZE]];
        [cell addSubview:biLabel];
        
        id ds=[dict objectForKey:@"datas"];
        if ([ds isKindOfClass:[NSArray class]]) {
        float w=(SCREEN_WIDTH-50)/4.0;
        for (int i=0; i<[ds count]; i++) {
            NSDictionary * dc=[ds objectAtIndex:i];
            UIButton* btn=[[UIButton alloc]initWithFrame:CGRectMake(5+w*i+10*i, 26, w, 32)];
            btn.tag=[[dc objectForKey:@"id"] integerValue];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
            [btn setTitleColor:DEFAULT_FONT_COLOR forState:UIControlStateNormal];
            [btn setTitle:[dc objectForKey:@"title"] forState:UIControlStateNormal];
            if (indexPath.row==1) {
                [btn addTarget:self action:@selector(onTypeButton:) forControlEvents:UIControlEventTouchUpInside];
            }else{
                [btn addTarget:self action:@selector(onStatusButton:) forControlEvents:UIControlEventTouchUpInside];
            }
            [btn.layer setBorderWidth:0.5];
            [btn.layer setMasksToBounds:YES];
            [btn.layer setCornerRadius:4.0f];
            
            UIImageView* iv=[[UIImageView alloc]initWithFrame:CGRectMake(w-8, 32-8, 8, 8)];
            [iv setTag:100];
            [iv setImage:[UIImage imageNamed:@"default_common_checkbutton_icon_highlighted@3x"]];
            [btn addSubview:iv];
            
            NSString* val=[UserDefaultHelper objectForKey:[dc objectForKey:@"valueKey"]];
            if ([val isEqualToString:[dc objectForKey:@"value"]]) {
                [iv setHidden:NO];
                [btn.layer setBorderColor:[DEFAULT_NAVIGATION_BACKGROUND_COLOR CGColor]];
            }else{
                [iv setHidden:YES];
                [btn.layer setBorderColor:[DEFAULT_LINE_COLOR CGColor]];
            }
    
            [cell addSubview:btn];
            }
        }
        UIImageView *separatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 63, self.frame.size.width-20, 0.5)];
        separatorImageView.backgroundColor=DEFAULT_LINE_COLOR;
        separatorImageView.opaque = YES;
        [cell.contentView addSubview:separatorImageView];
    }else{
        UILabel* biLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH-40, 30)];
        [biLabel setText:[dict objectForKey:@"title"]];
        [biLabel setFont:[UIFont boldSystemFontOfSize:FONT_SIZE]];
        
        [cell addSubview:biLabel];
        id ds=[dict objectForKey:@"datas"];
        if ([ds isKindOfClass:[NSArray class]]) {
            float w=(SCREEN_WIDTH-40)/3.0;
            for (int i=0; i<3; i++) {
                NSDictionary * dc=[ds objectAtIndex:i];
                UIButton* btn=[[UIButton alloc]initWithFrame:CGRectMake(5+w*i+10*i, 26, w, 32)];
                btn.tag=[[dc objectForKey:@"id"] integerValue];
                [btn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
                [btn setTitleColor:DEFAULT_FONT_COLOR forState:UIControlStateNormal];
                [btn setTitle:[dc objectForKey:@"title"] forState:UIControlStateNormal];
                if (indexPath.row==0) {
                    [btn addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
                }else{
                    [btn addTarget:self action:@selector(onChargeButton:) forControlEvents:UIControlEventTouchUpInside];
                }
                [btn.layer setBorderWidth:0.5];
                [btn.layer setMasksToBounds:YES];
                [btn.layer setCornerRadius:4.0f];
                
                UIImageView* iv=[[UIImageView alloc]initWithFrame:CGRectMake(w-8, 32-8, 8, 8)];
                [iv setTag:100];
                [iv setImage:[UIImage imageNamed:@"default_common_checkbutton_icon_highlighted@3x"]];
                [btn addSubview:iv];
                
                if (indexPath.row==0) {
                    NSInteger val=[[UserDefaultHelper objectForKey:[dc objectForKey:@"valueKey"]] integerValue];
                    if (val==[[dc objectForKey:@"value"] integerValue]) {
                        [iv setHidden:NO];
                        [btn.layer setBorderColor:[DEFAULT_NAVIGATION_BACKGROUND_COLOR CGColor]];
                    }else{
                        [iv setHidden:YES];
                        [btn.layer setBorderColor:[DEFAULT_LINE_COLOR CGColor]];
                    }
                }else{
                    NSString* val=[UserDefaultHelper objectForKey:[dc objectForKey:@"valueKey"]];
                    if ([val isEqualToString:[dc objectForKey:@"value"]]) {
                        [iv setHidden:NO];
                        [btn.layer setBorderColor:[DEFAULT_NAVIGATION_BACKGROUND_COLOR CGColor]];
                    }else{
                        [iv setHidden:YES];
                        [btn.layer setBorderColor:[DEFAULT_LINE_COLOR CGColor]];
                    }
                }
                
                [cell addSubview:btn];
            }
        }
        UIImageView *separatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 63, self.frame.size.width-20, 0.5)];
        separatorImageView.backgroundColor=DEFAULT_LINE_COLOR;
        separatorImageView.opaque = YES;
        [cell.contentView addSubview:separatorImageView];
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
    [[NSUserDefaults standardUserDefaults] setBool:sw.isOn forKey:CONF_PARKING_MOVE_SHOW];
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
    HLog(@".....%f",cell.frame.size.height);
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

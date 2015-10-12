//
//  SelectViewPopup.m
//  Parking
//
//  Created by xujunwu on 15/10/12.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import "SelectViewPopup.h"
#import "UserDefaultHelper.h"
#import "UIButton+Bootstrap.h"
#import <QuartzCore/QuartzCore.h>
#import "UIViewController+KeyboardAnimation.h"
#import "UIView+LoadingView.h"
#import "AppConfig.h"


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

@interface SelectViewPopup()

@property(nonatomic,strong)UIButton     *containerButton;

@end

@implementation SelectViewPopup
@synthesize containerButton;

- (id)initWithFrame:(CGRect)frame delegate:(id)aDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        delegate=aDelegate;
        self.containerButton = [[UIButton alloc] init];
        [self.containerButton setBackgroundColor:CONTAINER_BG_COLOR];
        [self.containerButton addTarget:self action:@selector(dismissPopover) forControlEvents:UIControlEventTouchUpInside];
        [self.containerButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin];
        
        // Adding Menu Options Pointer
        //        UIImageView *menuPointerView = [[UIImageView alloc] initWithFrame:MENU_POINTER_RECT];
        //        menuPointerView.backgroundColor=DEFAULT_FONT_COLOR;
        //        menuPointerView.tag = MENU_POINTER_TAG;
        //        [self.containerButton addSubview:menuPointerView];
        
        // Adding menu Items table
        [self loadData];
        
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

-(void)loadData
{
}

-(IBAction)onButton:(id)sender
{
    UIButton* btn=(UIButton*)sender;
    if ([delegate respondsToSelector:@selector(onSelectContent:forIndex:)]) {
            [delegate onSelectContent:self forIndex:btn.tag];
    }
}

#pragma mark -
#pragma mark UITableViewDatasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return MENU_ITEM_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = CELL_IDENTIGIER;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    UILabel * lb=[[UILabel alloc]initWithFrame:CGRectMake(10, 7, SCREEN_WIDTH-50, 30)];
    switch (indexPath.section) {
        case 0:
            [lb setText:@"请选择上报类型"];
            [lb setFont:[UIFont boldSystemFontOfSize:16.0f]];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            break;
        case 1:
        {
            [lb setText:@"地面停车场"];
            [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
            break;
        }
        case 2:
        {
            [lb setText:@"地下停车场"];
            [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
            break;
        }
        case 3:
        {
            [lb setText:@"道路停车场"];
            [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
            break;
        }
        case 4:
        {
            [lb setText:@"其他"];
            [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
            break;
        }
        default:
            break;
    }
    [lb setTextColor:DEFAULT_FONT_COLOR];
    [lb setTextAlignment:NSTextAlignmentCenter];
    [cell addSubview:lb];
    [self addSeparatorImageToCell:cell];
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section>0) {
        if ([delegate respondsToSelector:@selector(onSelectContent:forIndex:)]) {
            [delegate onSelectContent:self forIndex:indexPath.section];
        }
    }
}

#pragma mark -
#pragma mark Actions

- (void)dismissPopover
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


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
    
}
@end

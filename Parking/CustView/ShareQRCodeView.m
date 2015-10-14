//
//  ShareQRCodeView.m
//  Parking
//
//  Created by xujunwu on 15/10/11.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import "ShareQRCodeView.h"
#import "UserDefaultHelper.h"
#import <QuartzCore/QuartzCore.h>
#import "UIButton+Bootstrap.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>

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

@interface ShareQRCodeView()
{
    NSMutableArray      *data;
    UITableView         *mTableView;
    
    NSInteger           rowCount;
    
    BOOL                isQQInstall;
    BOOL                isWeixinInstall;
}
@property(nonatomic,strong)UIButton     *containerButton;

@end

@implementation ShareQRCodeView
@synthesize containerButton;

- (id)initWithFrame:(CGRect)frame delegate:(id)aDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        delegate=aDelegate;
        data=[[NSMutableArray alloc]init];
        rowCount=1;
        if (frame.size.height==MENU_ITEM_HEIGHT*2) {
            rowCount=2;
        }
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
        
        [self initShareData];

        [self.containerButton addSubview:self];
    }
    return self;
}

-(void)initShareData
{
    isWeixinInstall=NO;
    isQQInstall=NO;
    if ([TencentOAuth iphoneQQInstalled]&&[TencentOAuth iphoneQQSupportSSOLogin]) {
        isQQInstall=YES;
    }
    if ([WXApi isWXAppInstalled]) {
        isWeixinInstall=YES;
    }
}


-(IBAction)onButton:(id)sender
{
    UIButton* btn=(UIButton*)sender;
    
    if ([delegate respondsToSelector:@selector(onClickShareItem:forIndex:)]) {
        [delegate onClickShareItem:self forIndex:btn.tag];
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
    if (rowCount==1) {
        return SCREEN_HEIGHT/2.0;
    }
    return MENU_ITEM_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = CELL_IDENTIGIER;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if(rowCount==1){
        float h=SCREEN_HEIGHT/2.0-10;
        UIImageView* imageView=[[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-h)/2.0, 5, h, h)];
        [imageView setImage:[UIImage imageNamed:@"qrcode"]];
        [imageView setContentMode:UIViewContentModeScaleToFill];
        [cell addSubview:imageView];
 
    }else{
        float w=SCREEN_WIDTH/4;
        float h=46;
        for (int i=0; i<4; i++) {
            UIButton* btn=[[UIButton alloc]initWithFrame:CGRectMake(i*w+(w-46)/2,2, h, h)];
            [btn setTag:((indexPath.row+1)*10+i)];
            [btn setImage:[UIImage imageNamed:[self getShareIcon:indexPath.row forIndex:i]] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:btn];
            [self setSharedButton:btn forRow:indexPath.row forIndex:i];
            UILabel*  lb=[[UILabel alloc]initWithFrame:CGRectMake(i*w, 64-24, w, 26)];
            [lb setText:[self getShareTitle:indexPath.row forIndex:i]];
            [lb setTextAlignment:NSTextAlignmentCenter];
            [lb setFont:[UIFont systemFontOfSize:12.0]];
            [cell addSubview:lb];
        }
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    [self hide];
}

-(void)setSharedButton:(UIButton*)btn forRow:(NSInteger)row forIndex:(NSInteger)idx
{
    if (row==0) {
        switch (idx) {
            case 1:
                [btn setEnabled:isWeixinInstall];
                break;
            case 2:
                [btn setEnabled:isWeixinInstall];
                break;
            case 3:
                [btn setEnabled:isQQInstall];
            default:
                break;
        }
    }else{
        switch (idx) {
            case 0:
                [btn setEnabled:isQQInstall];
                break;
            default:
                break;
        }
    }
}

-(NSString*)getShareTitle:(NSInteger)row forIndex:(NSInteger)idx
{
    NSString* img=@"微博";
    if (row==0) {
        switch (idx) {
            case 0:
                img=@"微博";
                break;
            case 1:
                img=@"微信";
                break;
            case 2:
                img=@"朋友圈";
                break;
            case 3:
                img=@"QQ";
                break;
            default:
                break;
        }
    }else{
        switch (idx) {
            case 0:
                img=@"QQ空间";
                break;
            case 1:
                img=@"消息";
                break;
            case 2:
                img=@"邮件";
                break;
            case 3:
                img=@"二维码";
            default:
                break;
        }
    }
    return img;
}

-(NSString*)getShareIcon:(NSInteger)row forIndex:(NSInteger)idx
{
    NSString* img=@"share_platform_sina";
    if (row==0) {
        switch (idx) {
            case 0:
                img=@"share_platform_sina";
                break;
            case 1:
                img=@"share_platform_wechat";
                break;
            case 2:
                img=@"share_platform_wechattimeline";
                break;
            case 3:
                img=@"share_platform_qqfriends";
                break;
            default:
                break;
        }
    }else{
        switch (idx) {
            case 0:
                img=@"share_platform_qzone";
                break;
            case 1:
                img=@"share_platform_imessage";
                break;
            case 2:
                img=@"share_platform_email@2x";
                break;
            case 3:
                img=@"qrcode";
            default:
                break;
        }
    }
    return img;
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

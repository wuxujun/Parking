//
//  SubmitLayerPopup.m
//  Parking
//
//  Created by xujunwu on 15/9/18.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import "SubmitLayerPopup.h"
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

@interface SubmitLayerPopup()<UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    UITextField         *contentField;
    UIButton            *mapSelBtn;
    UIButton            *photoSelBtn;
    UIButton            *submitBtn;
    
    NSString            *fileName;
    NSString            *filePath;
    
}
@property(nonatomic,strong)UIButton     *containerButton;

@end

@implementation SubmitLayerPopup
@synthesize containerButton;

- (id)initWithFrame:(CGRect)frame delegate:(id)aDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        delegate=aDelegate;
        self.networkEngine=[[HNetworkEngine alloc]initWithHostName:nil customHeaderFields:nil];
        
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
            [self hide];
            break;
        }
        case 2:{
            break;
        }
        case 3:{
            
            break;
        }
        case 4:
        {
            [self submit];
            break;
        }
    }
    
//    if ([delegate respondsToSelector:@selector(viewSwitch:forIndex:)]) {
//        [delegate viewSwitch:self forIndex:btn.tag];
//    }
}

-(void)submit
{
    [self showHUDLoadingView:YES];
    NSString* requestUrl=[NSString stringWithFormat:@"%@report_parking",kHttpUrl];
    NSMutableDictionary* params=[[NSMutableDictionary alloc]init];
    [params setObject:@"1" forKey:@"reportType"];
    [params setObject:[NSString stringWithFormat:@"%@",contentField.text] forKey:@"reportName"];
    
    [params setObject:[NSString stringWithFormat:@"%@",contentField.text] forKey:@"reportLongti"];
    [params setObject:[NSString stringWithFormat:@"%@",contentField.text] forKey:@"reportLati"];
    [params setObject:[NSString stringWithFormat:@"%@",contentField.text] forKey:@"reportPhoto"];
    
    [self.networkEngine postOperationWithURLString:requestUrl params:params success:^(MKNetworkOperation *completedOperation, id result) {
        [self showHUDLoadingView:NO];
        if([[result objectForKey:@"status"] intValue]==200){
            
        }else{
            
        }
    } error:^(NSError *error) {
        HLog(@"%@",error);
        [self showHUDLoadingView:NO];
    }];
}

#pragma mark -
#pragma mark UITableViewDatasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1||indexPath.section==3) {
        return 60.0f;
    }else if(indexPath.section==2){
        float h=SCREEN_HEIGHT/2.0-120-44.0;
        return h;
    }
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
    if (indexPath.section==0) {
        
        UILabel * lb=[[UILabel alloc]initWithFrame:CGRectMake(10, 7, SCREEN_WIDTH-50, 30)];
        [lb setText:@"停车场上报"];
        [lb setTextColor:DEFAULT_FONT_COLOR];
        [lb setTextAlignment:NSTextAlignmentCenter];
        [cell addSubview:lb];
    
        UIButton* btn=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-40, 7, 30, 30)];
        [btn setTag:1];
        [btn setImage:[UIImage imageNamed:@"default_main_layer_close_normal"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btn];
    }else if(indexPath.section==1){
        contentField=[[UITextField alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH-20, 40)];
        [contentField.layer setBorderWidth:0.5];
        [contentField.layer setBorderColor:[DEFAULT_LINE_COLOR CGColor]];
        [contentField.layer setMasksToBounds:YES];
        [contentField.layer setCornerRadius:5.0f];
        [contentField setPlaceholder:@"请输入标题"];
        [cell addSubview:contentField];
    }else if(indexPath.section==2){
        float w=(SCREEN_WIDTH-30)/2.0;
        float h=SCREEN_HEIGHT/2.0-120-44.0;
        mapSelBtn=[[UIButton alloc]initWithFrame:CGRectMake(10, 5, w, h-10)];
        [mapSelBtn setTag:2];
        [mapSelBtn addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView* iv1=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"default_layer_selectposition_normal"] ];
        [iv1 setFrame:CGRectMake((w-56)/2, 15, 56, 56)];
        [mapSelBtn addSubview:iv1];
        
        
        UILabel* lb1=[[UILabel alloc]initWithFrame:CGRectMake(0, 20+56, w, 26)];
        [lb1 setText:@"地图精确选点"];
        [lb1 setFont:[UIFont systemFontOfSize:14.0f]];
        [lb1 setTextColor:DEFAULT_FONT_COLOR];
        [lb1 setTextAlignment:NSTextAlignmentCenter];
        [mapSelBtn addSubview:lb1];
        
        [cell addSubview:mapSelBtn];
        
        photoSelBtn=[[UIButton alloc]initWithFrame:CGRectMake(20+w, 5, w, h-10)];
        [photoSelBtn setTag:3];
        [photoSelBtn addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
        UIImageView* iv2=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"default_layer_takephoto_normal"]];
        [iv2 setFrame:CGRectMake((w-56)/2, 15, 56, 56)];
        [photoSelBtn addSubview:iv2];
        
        UILabel* lb2=[[UILabel alloc]initWithFrame:CGRectMake(0, 20+56, w, 26)];
        [lb2 setText:@"实时拍照"];
        [lb2 setFont:[UIFont systemFontOfSize:14.0f]];
        [lb2 setTextColor:DEFAULT_FONT_COLOR];
        [lb2 setTextAlignment:NSTextAlignmentCenter];
        [photoSelBtn addSubview:lb2];
        
        [cell addSubview:photoSelBtn];
    
    }else{
        submitBtn=[[UIButton alloc]initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH-20, 40)];
        [submitBtn setTag:4];
        [submitBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [submitBtn setTitle:@"立刻上报" forState:UIControlStateNormal];
        [submitBtn addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
        [submitBtn blueStyle];
        [cell addSubview:submitBtn];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [contentField resignFirstResponder];
}

-(void)showImagePicker:(BOOL)isCamera
{
//    BOOL hasCamera=[UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
//    if (!hasCamera) {
//        
//    }
//    UIImagePickerController* dController=[[UIImagePickerController alloc]init];
//    dController.delegate=self;
//    if (hasCamera&&isCamera) {
//        dController.sourceType=UIImagePickerControllerSourceTypeCamera;
//    }else{
//        dController.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
//    }
//    [self presentViewController:dController animated:YES completion:^{
//        
//    }];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    NSString* mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYYMMddhhmmss"];
    NSString *curTime=[formatter stringFromDate:[NSDate date] ];
    if ([mediaType isEqualToString:@"public.image"]) {
        fileName=[NSString stringWithFormat:@"%@.jpg",curTime];
        filePath=[NSString stringWithFormat:@"%@/%@",[[AppConfig getInstance] getDownPath],fileName];
        
        UIImage* image=[info objectForKey:UIImagePickerControllerOriginalImage];
        
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:UIImageJPEGRepresentation(image, 0.8) attributes:nil];
//        if (self.picImage) {
//            [self.picImage setImage:[UIImage imageNamed:filePath]];
//        }
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
//
//  RecordViewController.m
//  Parking
//
//  Created by xujunwu on 15/10/2.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import "RecordViewController.h"
#import "UIViewController+NavigationBarButton.h"
#import "PhotoViewController.h"
#import "UIButton+Bootstrap.h"
#import "DMLazyScrollView.h"
#import "AppConfig.h"


@interface RecordViewController ()<DMLazyScrollViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    
    NSString        *fileName;
    NSString        *filePath;
    
    UIView          * mHeadView;
    DMLazyScrollView    *mHeadScrollView;
    
    NSMutableArray      *photoDatas;
    NSMutableArray      *viewControllerArray;
}

@property(nonatomic,strong)UIButton     *camearButton;
@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    photoDatas=[[NSMutableArray alloc]init];
    viewControllerArray=[[NSMutableArray alloc] initWithCapacity:10];
    for (NSUInteger k=0 ; k<10; ++k) {
        [viewControllerArray addObject:[NSNull null]];
    }
    
    
    // Do any additional setup after loading the view.
    [self setCenterTitle:@"车位记录"];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"清空" style:UIBarButtonItemStylePlain target:self action:@selector(onClear:)];
    
    [self initView];
}

-(void)initView
{
    mHeadView=[[UIView alloc]initWithFrame:self.view.bounds];
    
    mHeadScrollView=[[DMLazyScrollView alloc]initWithFrame:mHeadView.frame];
    [mHeadScrollView setEnableCircularScroll:YES];
    [mHeadScrollView setAutoPlay:NO];
    mHeadScrollView.controlDelegate=self;
    [mHeadView addSubview:mHeadScrollView];
    mHeadScrollView.numberOfPages=0;
    [self.view addSubview:mHeadScrollView];
    
    __weak __typeof(&*self)weakSel=self;
    mHeadScrollView.dataSource=^(NSUInteger index){
        return [weakSel controllerAtIndex:index];
    };
    
    
    if (self.camearButton==nil) {
        self.camearButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [self.camearButton setFrame:CGRectMake(10, SCREEN_HEIGHT-54, SCREEN_WIDTH-20, 44.0)];
        [self.camearButton setTitle:@"拍照" forState:UIControlStateNormal];
        [self.camearButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.camearButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        [self.camearButton addTarget:self action:@selector(onCamera:) forControlEvents:UIControlEventTouchUpInside];
        [self.camearButton blueStyle];
        [self.view addSubview:self.camearButton];
    }
    [self readObject];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)onClear:(id)sender
{
    [photoDatas removeAllObjects];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSString* fPath=[NSString stringWithFormat:@"%@",[[AppConfig getInstance] getPhotoFilePath]];
    HLog(@"%@",fPath);
    if ([fileManager fileExistsAtPath:fPath]) {
        if ([fileManager removeItemAtPath:fPath error:nil]) {
        }
    }
    [self refresh];
}

-(IBAction)onCamera:(id)sender
{
    [self showImagePicker:YES];
}

-(void)refresh
{
    if ([photoDatas count]>0) {
        [mHeadScrollView setHidden:NO];
        
    }else{
        [mHeadScrollView setHidden:YES];
    }
}

-(UIViewController*)controllerAtIndex:(NSInteger)index
{
    if (index>photoDatas.count||index<0) {
        return nil;
    }
    
    id res=[viewControllerArray objectAtIndex:index%10];
    NSDictionary* dict=[photoDatas objectAtIndex:index];
    if (res==[NSNull null]) {
        PhotoViewController* viewController=[[PhotoViewController alloc]init];
        viewController.infoDict=dict;
        [viewControllerArray replaceObjectAtIndex:index%10 withObject:viewController];
        return viewController;
    }
    HLog(@"%@",dict);
    [(PhotoViewController*)res setInfoDict:dict];
    [(PhotoViewController*)res refresh];
    return res;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)showImagePicker:(BOOL)isCamera
{
    BOOL hasCamera=[UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (!hasCamera) {
        [self alertRequestResult:@"对不起,拍照功能不支持"];
    }
    UIImagePickerController* dController=[[UIImagePickerController alloc]init];
    if(IOS_VERSION_8_OR_ABOVE){
        dController.modalPresentationStyle=UIModalPresentationCurrentContext;
    }
    dController.delegate=self;
    if (hasCamera&&isCamera) {
        dController.sourceType=UIImagePickerControllerSourceTypeCamera;
    }else{
        dController.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:dController animated:YES completion:^{
        
    }];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    NSString* mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYYMMddhhmmss"];
    NSString *curTime=[formatter stringFromDate:[NSDate date] ];
    if ([mediaType isEqualToString:@"public.image"]) {
        fileName=[NSString stringWithFormat:@"%@.jpg",curTime];
        filePath=[NSString stringWithFormat:@"%@/%@",[[AppConfig getInstance] getPhotoFilePath],fileName];
        UIImage* image=[info objectForKey:UIImagePickerControllerOriginalImage];
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:UIImageJPEGRepresentation(image, 0.8) attributes:nil];
        NSDictionary* dict=[NSDictionary dictionaryWithObjectsAndKeys:@"3",@"dataType",fileName,@"image", nil];
        [photoDatas addObject:dict];
        mHeadScrollView.numberOfPages=[photoDatas count];
        [self saveObject];
        [self refresh];
    }
}

-(void)saveObject
{
    NSError* error;
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSString* fPath=[NSString stringWithFormat:@"%@/photos.plist",[[AppConfig getInstance] getPhotoFilePath]];
    if ([fileManager fileExistsAtPath:fPath]) {
        [fileManager removeItemAtPath:fPath error:&error];
    }
    [fileManager createFileAtPath:fPath contents:nil attributes:nil];
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
    [dict setObject:photoDatas forKey:@"root"];
    [dict writeToFile:fPath atomically:YES];
}

-(void)readObject
{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSString* fPath=[NSString stringWithFormat:@"%@/photos.plist",[[AppConfig getInstance] getPhotoFilePath]];
    HLog(@"%@",fPath);
    if ([fileManager fileExistsAtPath:fPath]) {
        NSMutableDictionary* dict=[NSMutableDictionary dictionaryWithContentsOfFile:fPath];
        if (dict&&[dict objectForKey:@"root"]) {
            id array=[dict objectForKey:@"root"];
            if ([array isKindOfClass:[NSArray class]]) {
                [photoDatas removeAllObjects];
                [photoDatas addObjectsFromArray:array];
            }
            if ([photoDatas count]>0) {
                mHeadScrollView.numberOfPages=[photoDatas count];
                [self refresh];
            }
        }
    }
}

@end

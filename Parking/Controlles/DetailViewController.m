//
//  DetailViewController.m
//  Parking
//
//  Created by xujunwu on 15/9/1.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "DetailViewController.h"
#import "UIViewController+NavigationBarButton.h"
#import "NaviViewController.h"
#import "LineViewController.h"
#import "DBManager.h"
#import "CollectEntity.h"
#import "PhotoViewController.h"

#import "DMLazyScrollView.h"

@interface DetailViewController()<DMLazyScrollViewDelegate>
{
    UIView          * mHeadView;
    DMLazyScrollView    *mHeadScrollView;
    
    NSMutableArray      *photoDatas;
    NSMutableArray      *viewControllerArray;
    int             sourceType;
}
@end

@implementation DetailViewController
@synthesize startPoint=_startPoint;

-(void)viewDidLoad
{
    [super viewDidLoad];
    photoDatas=[[NSMutableArray alloc]init];
    viewControllerArray=[[NSMutableArray alloc] initWithCapacity:10];
    for (NSUInteger k=0 ; k<10; ++k) {
        [viewControllerArray addObject:[NSNull null]];
    }
    
    [self setCenterTitle:@"停车场详情"];
    [self addRightFavoriteButton:NO action:@selector(onCollect:)];
    
    if (self.dataType==2) {
        [self setCenterTitle:@"公共自行车点详情"];
    }
    _tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    [self initHeadView];
    if (self.infoDict) {
        HLog(@"%@",self.infoDict);
        sourceType=[[self.infoDict objectForKey:@"sourceType"] intValue];
        NSInteger count=[[DBManager getInstance] queryCollectCountWithId:[self.infoDict objectForKey:@"poiId"]];
        if (count>0) {
            [self addRightFavoriteButton:YES action:@selector(onCollect:)];
        }
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([[self.infoDict objectForKey:@"sourceType"] intValue]==1&&[[self.infoDict objectForKey:@"dataType"] intValue]==1) {
        [self loadDetail];
    }else{
        [photoDatas addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1",@"dataType", nil]];
        mHeadScrollView.numberOfPages=1;
    }
}

-(void)loadDetail
{
    NSString *requestUrl=[NSString stringWithFormat:@"%@parking_detail",kHttpUrl];
    NSMutableDictionary* params=[[NSMutableDictionary alloc]init];
    [params setObject:[self.infoDict objectForKey:@"poiId"] forKey:@"parkId"];
    [self.networkEngine postOperationWithURLString:requestUrl params:params success:^(MKNetworkOperation *completedOperation, id result) {
        HLog(@"%@",result);
        if([[result objectForKey:@"status"] intValue]==200){
            NSArray*    array=[result objectForKey:@"photoLink"];
            if (array&&[array count]>0) {
                for (int i=0;i<[array count];i++) {
                    if (i>0) {
                        [photoDatas addObject:[array objectAtIndex:i]];
                    }
                }
                mHeadScrollView.numberOfPages=photoDatas.count;
            }
            
        }
    } error:^(NSError *error) {
        HLog(@"%@",error);
    }];
    
}

-(IBAction)onCollect:(id)sender
{
    NSInteger count=[[DBManager getInstance] queryCollectCountWithId:[self.infoDict objectForKey:@"uid"]];
    if (count>0) {
        [[DBManager getInstance] deleteCollect:[self.infoDict objectForKey:@"uid"]];
        [self addRightFavoriteButton:NO action:@selector(onCollect:)];
    }else{
        NSMutableDictionary* dict=[[NSMutableDictionary alloc]init];
        [dict setObject:@"0" forKey:@"favType"];
        [dict setObject:[self.infoDict objectForKey:@"title"] forKey:@"title"];
        [dict setObject:[self.infoDict objectForKey:@"latitude"] forKey:@"latitude"];
        [dict setObject:[self.infoDict objectForKey:@"longitude"] forKey:@"longitude"];
        [dict setObject:[self.infoDict objectForKey:@"address"] forKey:@"address"];
        [dict setObject:[self.infoDict objectForKey:@"sourceType"] forKey:@"sourceType"];
        [dict setObject:[self.infoDict objectForKey:@"dataType"] forKey:@"dataType"];
        [dict setObject:[NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]] forKey:@"favTime"];
        [dict setObject:[self.infoDict objectForKey:@"poiId"] forKey:@"dataId"];
        
        HLog(@"%@",dict);
        [[DBManager getInstance] insertOrUpdateCollect:dict];
        [self addRightFavoriteButton:YES action:@selector(onCollect:)];
    }
}

-(void)initHeadView
{
    mHeadView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 180)];
    
    mHeadScrollView=[[DMLazyScrollView alloc]initWithFrame:mHeadView.frame];
    [mHeadScrollView setEnableCircularScroll:NO];
    [mHeadScrollView setAutoPlay:NO];
    mHeadScrollView.controlDelegate=self;
    [mHeadView addSubview:mHeadScrollView];
    mHeadScrollView.numberOfPages=0;
    
    [mHeadView addSubview:mHeadScrollView];
    
    [_tableView setTableHeaderView:mHeadView];
    
    UIView* footer=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    
    float w=(SCREEN_WIDTH-30)/2;
    UIButton* btnLine=[[UIButton alloc]initWithFrame:CGRectMake(10, (64-40)/2, w,40)];
    [btnLine setTag:1];
    [btnLine.layer setCornerRadius:5.0f];
    [btnLine.layer setBorderColor:[DEFAULT_LINE_COLOR CGColor]];
    [btnLine.layer setBorderWidth:1.0];
    [btnLine.layer setMasksToBounds:YES];
    [btnLine.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [btnLine setTitle:@"路线" forState:UIControlStateNormal];
    [btnLine setTitleColor:DEFAULT_FONT_COLOR forState:UIControlStateNormal];
    [btnLine addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView* lineIV=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"default_main_toolbaritem_path_normal"]];
    [lineIV setFrame:CGRectMake(w/2-35, (40-18)/2, 18, 18)];
    [btnLine addSubview:lineIV];

    
    [footer addSubview:btnLine];
    
    UIButton* btnNavi=[[UIButton alloc]initWithFrame:CGRectMake(20+w, (64-40)/2, w,40)];
    [btnNavi setTag:2];
    [btnNavi.layer setCornerRadius:5.0f];
    [btnNavi.layer setBorderColor:[DEFAULT_LINE_COLOR CGColor]];
    [btnNavi.layer setBorderWidth:1.0];
    [btnNavi.layer setMasksToBounds:YES];
    [btnNavi.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [btnNavi setTitle:@"导航" forState:UIControlStateNormal];
    [btnNavi setTitleColor:DEFAULT_FONT_COLOR forState:UIControlStateNormal];
    [btnNavi setTitleColor:DEFAULT_NAVIGATION_BACKGROUND_COLOR forState:UIControlStateHighlighted];
    [btnNavi addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView* naviIV=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"default_main_toolbaritem_navi_normal"]];
    [naviIV setFrame:CGRectMake(w/2-35, (40-18)/2, 18, 18)];
    [btnNavi addSubview:naviIV];

    
    [footer addSubview:btnNavi];
    [_tableView setTableFooterView:footer];
    
    
    __weak __typeof(&*self)weakSel=self;
    mHeadScrollView.dataSource=^(NSUInteger index){
        return [weakSel controllerAtIndex:index];
    };

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
    [(PhotoViewController*)res setInfoDict:dict];
    [(PhotoViewController*)res refresh];
    return res;
}

-(IBAction)onButton:(id)sender
{
    UIButton* btn=(UIButton*)sender;
    if (btn.tag==1) {
        LineViewController* dController=[[LineViewController alloc]init];
        dController.lineType=self.dataType;
        dController.startPoint=self.startPoint;
        dController.endPoint=self.infoDict;
        [self.navigationController pushViewController:dController animated:YES];
    }else{
        NaviViewController* dController=[[NaviViewController alloc]init];
        dController.naviType=self.dataType;
        dController.startPoint=self.startPoint;
        dController.endPoint=self.infoDict;
        [self.navigationController pushViewController:dController animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    NSString *title=@"类型:";
    NSString *content=[self.infoDict objectForKey:@"typeDes"];
    if ([content isEqualToString:@"2"]) {
        content=@"公共自行车点";
    }
    switch (indexPath.row) {
        case 0:
        {
            if ([self.infoDict objectForKey:@"title"]) {
                
                cell.textLabel.text=[self.infoDict objectForKey:@"title"];
                if(sourceType==1&&self.dataType==2) {
                    cell.textLabel.text=[NSString stringWithFormat:@"[%@]%@",[self.infoDict objectForKey:@"poiId"],[self.infoDict objectForKey:@"title"]];
                }
                cell.textLabel.font=[UIFont boldSystemFontOfSize:18.0f];
            }
            break;
        }
        case 2:{
            title=@"位置:";
            if (sourceType==1&&self.dataType==2) {
                title=@"地址:";
            }
            content=[self.infoDict objectForKey:@"address"];
            break;
        }
        case 3:{
            title=@"价格:";
            content=@"";
            if ([self.infoDict objectForKey:@"chargeDetail"]) {
                content=[self.infoDict objectForKey:@"chargeDetail"];
            }
            if (sourceType==1&&self.dataType==2) {
                title=@"车位:";
                if ([self.infoDict objectForKey:@"freeCount"]&&[self.infoDict objectForKey:@"totalCount"]) {
                    content=[NSString stringWithFormat:@"%@/%@",[self.infoDict objectForKey:@"freeCount"],[self.infoDict objectForKey:@"totalCount"]];
                }
            }
            if(sourceType==0&&self.dataType==2){
                title=@"";
            }
            
            break;
        }
        default:
        {
            
        }
            break;
    }
   
    if (indexPath.row>0) {
        UILabel* lb=[[UILabel alloc]initWithFrame:CGRectMake(15, 5, 50, 54)];
        [lb setText:title];
        [lb setTextColor:DEFAULT_FONT_COLOR];
        [cell addSubview:lb];
        
        UILabel* desc=[[UILabel alloc]initWithFrame:CGRectMake(60, 5, SCREEN_WIDTH-70, 54)];
        [desc setText:content];
        [desc setLineBreakMode:NSLineBreakByCharWrapping];
        [desc setFont:[UIFont systemFontOfSize:14.0f]];
        [desc setNumberOfLines:0];
        [desc setTextColor:DEFAULT_FONT_COLOR];
        [cell addSubview:desc];
    }

    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

@end

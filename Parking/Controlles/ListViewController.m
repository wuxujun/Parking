//
//  ListViewController.m
//  Parking
//
//  Created by xujunwu on 15/8/31.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "ListViewController.h"
#import "UIViewController+NavigationBarButton.h"
#import "ListViewCell.h"
#import "LineViewController.h"
#import "NaviViewController.h"
#import "DetailViewController.h"
#import "BListViewController.h"
#import "DBManager.h"
#import "PoiInfoEntity.h"
#import "SIAlertView.h"
#import "UserDefaultHelper.h"

@interface ListViewController()<ListViewCellDelegate>
{
    UIButton            *cityButton;
    UIButton            *typeButton;
    
    NSString*           currentCharge;
    NSString*           currentType;
    
}
@end

@implementation ListViewController
@synthesize dataType,sourceType,startPoint;

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"default_common_map_icon_normal"] style:UIBarButtonItemStylePlain target:self action:@selector(showMap:)];
    currentCharge=@"0";
    currentType=@"0";
    
//    if (self.sourceType==1&&self.dataType==1) {
//        _tableView.frame=CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-44);
//        [self initHeadView];
//    }
    _tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
}

-(void)initHeadView
{
    float width=self.view.frame.size.width;
    UIView* headView=[[UIView alloc]initWithFrame:CGRectMake(0, 64, width, 40)];
    [headView setBackgroundColor:[UIColor whiteColor]];
    if (cityButton==nil) {
        cityButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, width/2.0, 39)];
        [cityButton setTitle:@"价格不限" forState:UIControlStateNormal];
        [cityButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cityButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [cityButton addTarget:self action:@selector(citySelected:) forControlEvents:UIControlEventTouchUpInside];
        [headView addSubview:cityButton];
    }
    if (typeButton==nil) {
        typeButton=[[UIButton alloc]initWithFrame:CGRectMake(width/2.0, 0, width/2.0, 39)];
        [typeButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [typeButton setTitle:@"全部分类" forState:UIControlStateNormal];
        [typeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [typeButton addTarget:self action:@selector(typeSelected:) forControlEvents:UIControlEventTouchUpInside];
        [headView addSubview:typeButton];
    }
    UIImageView *line=[[UIImageView alloc]initWithFrame:CGRectMake(0, 40, width, 0.5f)];
    [line setBackgroundColor:DEFAULT_LINE_COLOR];
    [headView addSubview:line];
    [self.view addSubview:headView];
}

-(IBAction)citySelected:(id)sender
{
    SIAlertView* alertView=[[SIAlertView alloc]initWithTitle:nil andMessage:nil];
    [alertView addButtonWithTitle:@"价格不限" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
        currentCharge=@"2";
        [cityButton setTitle:@"价格不限" forState:UIControlStateNormal];
        [UserDefaultHelper setObject:currentCharge forKey:CONF_PARKING_MAP_CHARGE];
        [self loadLocalData];
    }];
    [alertView addButtonWithTitle:@"免费" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
        currentCharge=@"0";
        [cityButton setTitle:@"免费" forState:UIControlStateNormal];
        [UserDefaultHelper setObject:currentCharge forKey:CONF_PARKING_MAP_CHARGE];
        [self loadLocalData];
    }];
    [alertView addButtonWithTitle:@"收费" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
        currentCharge=@"1";
        [cityButton setTitle:@"收费" forState:UIControlStateNormal];
        [UserDefaultHelper setObject:currentCharge forKey:CONF_PARKING_MAP_CHARGE];
        [self loadLocalData];
    }];
    alertView.transitionStyle=SIAlertViewTransitionStyleSlideFromTop;
    [alertView show];
    
}

-(IBAction)typeSelected:(id)sender
{
    SIAlertView* alertView=[[SIAlertView alloc]initWithTitle:nil andMessage:nil];
    
    [alertView addButtonWithTitle:@"全部类型" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
        currentType=@"0";
        [typeButton setTitle:@"全部类型" forState:UIControlStateNormal];
        [UserDefaultHelper setObject:currentType forKey:CONF_PARKING_MAP_TYPE];
        [self loadLocalData];
    }];
    [alertView addButtonWithTitle:@"道路停车场" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
        currentType=@"道路停车场";
        [typeButton setTitle:currentType forState:UIControlStateNormal];
        [UserDefaultHelper setObject:currentType forKey:CONF_PARKING_MAP_TYPE];
        [self loadLocalData];
    }];
    [alertView addButtonWithTitle:@"地面停车场" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
        currentType=@"地面停车场";
        [typeButton setTitle:currentType forState:UIControlStateNormal];
        [UserDefaultHelper setObject:currentType forKey:CONF_PARKING_MAP_TYPE];
        [self loadLocalData];
    }];
    [alertView addButtonWithTitle:@"地下停车场" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
        currentType=@"地下停车场";
        [typeButton setTitle:currentType forState:UIControlStateNormal];
        [UserDefaultHelper setObject:currentType forKey:CONF_PARKING_MAP_TYPE];
        [self loadLocalData];
    }];
    [alertView addButtonWithTitle:@"其他" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
        currentType=@"其他";
        [typeButton setTitle:currentType forState:UIControlStateNormal];
        [UserDefaultHelper setObject:currentType forKey:CONF_PARKING_MAP_TYPE];
        [self loadLocalData];
    }];
    alertView.transitionStyle=SIAlertViewTransitionStyleSlideFromTop;
    [alertView show];
}
-(void)loadLocalData
{
    NSString* charge=[UserDefaultHelper objectForKey:CONF_PARKING_MAP_CHARGE];
    if ([charge isEqualToString:@"0"]) {
        [cityButton setTitle:@"免费" forState:UIControlStateNormal];
        currentCharge=@"0";
    }else if([charge isEqualToString:@"1"]){
        [cityButton setTitle:@"收费" forState:UIControlStateNormal];
        currentCharge=@"1";
    }else{
        [cityButton setTitle:@"价格不限" forState:UIControlStateNormal];
        currentCharge=@"2";
    }
    
    NSString* type=[UserDefaultHelper objectForKey:CONF_PARKING_MAP_TYPE];
    if ([type isEqualToString:@"0"]) {
        currentType=@"0";
        [typeButton setTitle:@"全部类型" forState:UIControlStateNormal];
    }else{
        currentType=type;
        [typeButton setTitle:currentType forState:UIControlStateNormal];
    }
    
    [_datas removeAllObjects];
    NSArray* array=[[DBManager getInstance] queryPoiInfo:currentCharge forType:currentType];
    if ([array count]>0) {
        [_datas addObjectsFromArray:array];
    }
    [_tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.dataType==1){
        [self setCenterTitle:@"停车场列表"];
    }else if(self.dataType==2){
        [self setCenterTitle:@"公共自行车列表"];
    }else{
        [self setCenterTitle:@"公交站列表"];
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadLocalData];
}


-(IBAction)showMap:(id)sender
{
    [UserDefaultHelper setObject:@"1" forKey:CONF_LIST_TO_MAP];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0f;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return [_datas count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    PoiInfoEntity* entity=[_datas objectAtIndex:indexPath.row];
    if (entity) {
        ListViewCell* item=[[ListViewCell alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100) delegate:self];
        item.dataType=self.dataType;
        item.infoDict=[NSDictionary dictionaryWithObjectsAndKeys:entity.title,@"title",entity.poiId,@"poiId",entity.typeDes,@"typeDes",entity.address,@"address",[NSString stringWithFormat:@"%d",entity.distance],@"distance",entity.latitude,@"latitude",entity.longitude,@"longitude",[NSString stringWithFormat:@"%d",entity.dataType],@"dataType",[NSString stringWithFormat:@"%d",entity.idx],@"idx",entity.charge,@"charge",entity.chargeDetail,@"chargeDetail",@"0",@"price",[NSString stringWithFormat:@"%d",entity.totalCount],@"totalCount",[NSString stringWithFormat:@"%d",entity.freeCount],@"freeCount",[NSString stringWithFormat:@"%d",entity.sourceType],@"sourceType",entity.cityCode,@"cityCode",entity.adCode,@"adCode",entity.freeStatus,@"freeStatus", nil];
        [cell addSubview:item];
    }
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)onListViewCellClicked:(ListViewCell*)view forIndex:(int)idx
{
    switch (idx) {
        case 0:
        {
            if (self.dataType==3) {
                BListViewController* dController=[[BListViewController alloc]init];
                dController.infoDict=view.infoDict;
                dController.startPoint=self.startPoint;
                [self.navigationController pushViewController:dController animated:YES];
            }else{
                DetailViewController* dController=[[DetailViewController alloc]init];
                dController.infoDict=view.infoDict;
                [self.navigationController pushViewController:dController animated:YES];
            }
            break;
        }
        case 1:
        {
            LineViewController* dController=[[LineViewController alloc]init];
            dController.lineType=self.dataType;
            [dController setStartPoint:self.startPoint];
            [dController setEndPoint:view.infoDict];
            [self.navigationController pushViewController:dController animated:YES];
        }
            break;
        case 2:
        {
            NaviViewController* dController=[[NaviViewController alloc]init];
            [dController setNaviType:self.dataType];
            [dController setStartPoint:self.startPoint];
            [dController setEndPoint:view.infoDict];
            [self.navigationController pushViewController:dController animated:YES];
            break;
        }
        default:
            break;
    }
}

@end

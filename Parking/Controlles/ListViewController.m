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
    
    _tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
}

-(NSString*)caclDistanceForEntity:(PoiInfoEntity*)entity
{
    MAMapPoint point1 = MAMapPointForCoordinate(CLLocationCoordinate2DMake([[UserDefaultHelper objectForKey:CONF_CURRENT_TARGET_LATITUDE] floatValue],[[UserDefaultHelper objectForKey:CONF_CURRENT_TARGET_LONGITUDE] floatValue]));
    MAMapPoint point2 = MAMapPointForCoordinate(CLLocationCoordinate2DMake([entity.latitude floatValue],[entity.longitude floatValue]));
    //计算距离
    CLLocationDistance distance = MAMetersBetweenMapPoints(point1,point2);
    NSString* distanceStr=[NSString stringWithFormat:@"%.0f",distance];
    return distanceStr;
}

-(void)loadLocalData
{
    [_datas removeAllObjects];
    NSString *charge=[UserDefaultHelper objectForKey:CONF_PARKING_MAP_CHARGE];
    NSString* status=[UserDefaultHelper objectForKey:CONF_PARKING_MAP_STATUS];
    NSString* type=[UserDefaultHelper objectForKey:CONF_PARKING_MAP_TYPE];
    if (self.dataType!=1) {
        charge=@"0";
        status=@"0";
        type=@"0";
    }
    NSString* lat=[UserDefaultHelper objectForKey:CONF_CURRENT_TARGET_LATITUDE];
    NSString* lng=[UserDefaultHelper objectForKey:CONF_CURRENT_TARGET_LONGITUDE];

    if (self.sourceType==0) {
        NSArray* array=[[DBManager getInstance] queryOtherCity];
        if ([array count]>0) {
            [_datas addObjectsFromArray:array];
        }
    }else{
       NSArray* array=[[DBManager getInstance] queryPoiInfo:[UserDefaultHelper objectForKey:CONF_PARKING_MAP_CHARGE] forType:[UserDefaultHelper objectForKey:CONF_PARKING_MAP_TYPE] forStatus:[UserDefaultHelper objectForKey:CONF_PARKING_MAP_STATUS] forLat:lat forLng:lng];
        if ([array count]>0) {
            int idx=0;
            NSMutableArray  *localDatas=[[NSMutableArray alloc]init];
            for (PoiInfoEntity *entity in array) {
                NSDictionary* dict=[NSDictionary dictionaryWithObjectsAndKeys:entity.title,@"title",entity.poiId,@"poiId",entity.typeDes,@"typeDes",entity.address,@"address",[NSString stringWithFormat:@"%@",[self caclDistanceForEntity:entity]],@"distance",entity.latitude,@"latitude",entity.longitude,@"longitude",[NSString stringWithFormat:@"%d",entity.dataType],@"dataType",entity.charge,@"charge",entity.chargeDetail,@"chargeDetail",@"0",@"price",[NSString stringWithFormat:@"%d",entity.totalCount],@"totalCount",[NSString stringWithFormat:@"%d",entity.freeCount],@"freeCount",[NSString stringWithFormat:@"%d",entity.sourceType],@"sourceType",entity.cityCode,@"cityCode",entity.adCode,@"adCode",entity.freeStatus,@"freeStatus",entity.shopHours,@"shopHours",entity.thumbUrl,@"thumbUrl", nil];
                [localDatas addObject:dict];
            }
            //排序
            NSArray* pois=[localDatas sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                NSDictionary* p1=(NSDictionary*)obj1;
                NSDictionary* p2=(NSDictionary*)obj2;
                if ([[p1 objectForKey:@"distance"] integerValue]<[[p2 objectForKey:@"distance"] integerValue]) {
                    return NSOrderedAscending;
                }else if([[p1 objectForKey:@"distance"] integerValue]>[[p2 objectForKey:@"distance"] integerValue]){
                    return NSOrderedDescending;
                }else{
                    return NSOrderedSame;
                }
            }];
            //重置序号
            for (NSDictionary *entity in pois) {
                NSMutableDictionary* dict=[NSMutableDictionary dictionaryWithDictionary:entity];
                [dict setObject:[NSString stringWithFormat:@"%d",(idx+1)] forKey:@"idx"];
                //                HLog(@"%@",dict);
                [_datas addObject:dict];
                idx++;
            }
        }

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
    }else if(self.dataType==3){
        [self setCenterTitle:@"公交站列表"];
    }else{
        [self setCenterTitle:@"目的的列表"];
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
    if (self.sourceType==0) {
        PoiInfoEntity* entity=[_datas objectAtIndex:indexPath.row];
        if (entity) {
            ListViewCell* item=[[ListViewCell alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100) delegate:self];
            item.dataType=self.dataType;
            item.infoDict=[NSDictionary dictionaryWithObjectsAndKeys:entity.title,@"title",entity.poiId,@"poiId",entity.typeDes,@"typeDes",entity.address,@"address",[NSString stringWithFormat:@"%d",entity.distance],@"distance",entity.latitude,@"latitude",entity.longitude,@"longitude",[NSString stringWithFormat:@"%d",entity.dataType],@"dataType",[NSString stringWithFormat:@"%d",entity.idx],@"idx",entity.charge,@"charge",entity.chargeDetail,@"chargeDetail",@"0",@"price",[NSString stringWithFormat:@"%d",entity.totalCount],@"totalCount",[NSString stringWithFormat:@"%d",entity.freeCount],@"freeCount",[NSString stringWithFormat:@"%d",entity.sourceType],@"sourceType",entity.cityCode,@"cityCode",entity.adCode,@"adCode",entity.freeStatus,@"freeStatus",entity.shopHours,@"shopHours",entity.thumbUrl,@"thumbUrl", nil];
            [cell addSubview:item];
        }
    }else{
        NSDictionary* dict=[_datas objectAtIndex:indexPath.row];
        ListViewCell* item=[[ListViewCell alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100) delegate:self];
        item.dataType=self.dataType;
        item.infoDict=dict;
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
                dController.cityCode=self.cityCode;
                [self.navigationController pushViewController:dController animated:YES];
            }else{
                DetailViewController* dController=[[DetailViewController alloc]init];
                dController.infoDict=view.infoDict;
                dController.cityCode=self.cityCode;
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
            [dController setCityCode:self.cityCode];
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

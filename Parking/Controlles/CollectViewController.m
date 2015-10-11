//
//  CollectViewController.m
//  Parking
//
//  Created by xujunwu on 15/9/16.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "CollectViewController.h"
#import "UIViewController+NavigationBarButton.h"
#import "DBManager.h"
#import "UserDefaultHelper.h"
#import "CollectEntity.h"
#import "LineViewController.h"
#import "NaviViewController.h"
#import "BListViewController.h"
#import "DetailViewController.h"

@interface CollectViewController()

@property(nonatomic,strong)NSDictionary*    startPoint;
@end

@implementation CollectViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setCenterTitle:@"我的收藏"];
    
    _tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;

    self.startPoint=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%.6f",[[UserDefaultHelper objectForKey:CONF_LOCATION_LATITUDE] doubleValue]],@"latitude",[NSString stringWithFormat:@"%.6f",[[UserDefaultHelper objectForKey:CONF_LOCATION_LONGITUDE] doubleValue]],@"longitude", nil];
    [self loadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

-(void)loadData
{
    [_datas removeAllObjects];
    NSArray* array=[[DBManager getInstance] queryCollect];
    if ([array count]>0) {
        [_datas addObjectsFromArray:array];
        [_tableView reloadData];
    }
    
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 96.0;
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
    CollectEntity* entity=[_datas objectAtIndex:indexPath.row];
    UILabel*    title=[[UILabel alloc]initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH-20, 30)];
    [title setText:[NSString stringWithFormat:@"%d.%@",(indexPath.row+1),entity.title]];
    [title setFont:[UIFont systemFontOfSize:14.0]];
    [title setTextColor:DEFAULT_FONT_COLOR];
    [cell addSubview:title];
    
    UILabel*    content=[[UILabel alloc]initWithFrame:CGRectMake(10, 28, SCREEN_WIDTH-20, 30)];
    [content setText:entity.address];
    [content setFont:[UIFont systemFontOfSize:12.0]];
    [content setNumberOfLines:0];
    [content setLineBreakMode:NSLineBreakByCharWrapping];
    [content setTextColor:DEFAULT_FONT_COLOR];
    [cell addSubview:content];

    UIButton* line=[[UIButton alloc]initWithFrame:CGRectMake(15, 56, (SCREEN_WIDTH-40)/2, 36)];
    [line setTag:indexPath.row];
    [line setTitle:@"路线" forState:UIControlStateNormal];
    [line setTitleColor:DEFAULT_FONT_COLOR forState:UIControlStateNormal];
    [line setTitleColor:DEFAULT_NAVIGATION_BACKGROUND_COLOR forState:UIControlStateHighlighted];
    [line.layer setCornerRadius:5.0];
    [line.layer setMasksToBounds:YES];
    [line.layer setBorderWidth:0.5];
    [line.layer setBorderColor:[DEFAULT_LINE_COLOR CGColor]];
    [line addTarget:self action:@selector(onLine:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:line];
    
    UIButton* navi=[[UIButton alloc]initWithFrame:CGRectMake(25+(SCREEN_WIDTH-40)/2, 56, (SCREEN_WIDTH-40)/2, 36)];
    [navi setTag:indexPath.row];
    [navi setTitle:@"导航" forState:UIControlStateNormal];
    [navi setTitleColor:DEFAULT_FONT_COLOR forState:UIControlStateNormal];
    [navi setTitleColor:DEFAULT_NAVIGATION_BACKGROUND_COLOR forState:UIControlStateHighlighted];
    [navi.layer setCornerRadius:5.0];
    [navi.layer setMasksToBounds:YES];
    [navi.layer setBorderWidth:0.5];
    [navi.layer setBorderColor:[DEFAULT_LINE_COLOR CGColor]];
    [navi addTarget:self action:@selector(onNavi:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:navi];

    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CollectEntity* entity=[_datas objectAtIndex:indexPath.row];
    if (entity) {
        NSDictionary* dict=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",entity.title],@"title",[NSString stringWithFormat:@"%@",entity.dataId],@"poiId",@"0",@"typeDes",[NSString stringWithFormat:@"%@",entity.address],@"address",@"0",@"distance",entity.latitude,@"latitude",entity.longitude,@"longitude",[NSString stringWithFormat:@"%d",entity.dataType],@"dataType",@"0",@"idx",@"0",@"charge",@"0",@"chargeDetail",@"0",@"price",@"0",@"totalCount",@"0",@"freeCount",[NSString stringWithFormat:@"%d",entity.sourceType],@"sourceType",@"0",@"cityCode",@"0",@"adCode",@"0",@"freeStatus", nil];
        if (entity.dataType==3) {
            BListViewController* dController=[[BListViewController alloc]init];
            dController.infoDict=dict;
            [dController setStartPoint:self.startPoint];
            [self.navigationController pushViewController:dController animated:YES];
        }else{
            DetailViewController* dController=[[DetailViewController alloc]init];
            dController.dataType=entity.dataType;
            [dController setStartPoint:self.startPoint];
            [dController setInfoDict:dict];
            [self.navigationController pushViewController:dController animated:YES];
        }
    }
    
}

-(IBAction)onLine:(id)sender
{
    UIButton* btn=(UIButton*)sender;
    CollectEntity* entity=[_datas objectAtIndex:btn.tag];
    if (entity) {
        LineViewController* dController=[[LineViewController alloc]init];
        dController.lineType=entity.dataType;
        dController.startPoint=self.startPoint;
        dController.endPoint=[NSDictionary dictionaryWithObjectsAndKeys:entity.latitude,@"latitude",entity.longitude,@"longitude", nil];
        [self.navigationController pushViewController:dController animated:YES];
    }
}

-(IBAction)onNavi:(id)sender
{
    UIButton* btn=(UIButton*)sender;
    CollectEntity* entity=[_datas objectAtIndex:btn.tag];
    if (entity) {
        NaviViewController* dController=[[NaviViewController alloc]init];
        dController.naviType=entity.dataType;
        dController.startPoint=self.startPoint;
        dController.endPoint=[NSDictionary dictionaryWithObjectsAndKeys:entity.latitude,@"latitude",entity.longitude,@"longitude", nil];
        [self.navigationController pushViewController:dController animated:YES];
    }
}

@end

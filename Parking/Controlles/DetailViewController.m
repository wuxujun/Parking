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


@interface DetailViewController()
@end

@implementation DetailViewController
@synthesize startPoint=_startPoint;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setCenterTitle:@"停车场详情"];
    [self addRightFavoriteButton:NO action:@selector(onCollect:)];
    
    if (self.dataType==2) {
        [self setCenterTitle:@"公共自行车点详情"];
    }
    _tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    [self initHeadView];
    if (self.infoDict) {
        HLog(@"%@",self.infoDict);
        NSInteger count=[[DBManager getInstance] queryCollectCountWithId:[self.infoDict objectForKey:@"uid"]];
        if (count>0) {
            [self addRightFavoriteButton:YES action:@selector(onCollect:)];
        }
    }
}

-(void)loadDetail
{
    NSString *request=[NSString stringWithFormat:@"%@parking_detail",kHttpUrl];
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
        [dict setObject:[self.infoDict objectForKey:@"uid"] forKey:@"dataId"];
        
        HLog(@"%@",dict);
        [[DBManager getInstance] insertOrUpdateCollect:dict];
        [self addRightFavoriteButton:YES action:@selector(onCollect:)];
    }
}

-(void)initHeadView
{
    UIView * bg=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 150)];
    
    
    UIImageView* iv=[[UIImageView alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH-20, 130)];
    [iv setImage:[UIImage imageNamed:@"parking"]];
    [iv setContentMode:UIViewContentModeScaleToFill];
    [bg addSubview:iv];
    
    [_tableView setTableHeaderView:bg];
    
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
                cell.textLabel.font=[UIFont boldSystemFontOfSize:18.0f];
            }
            break;
        }
        case 2:{
            title=@"位置:";
            content=[self.infoDict objectForKey:@"address"];
            break;
        }
        case 3:{
            title=@"价格:";
            content=@"";
            if ([self.infoDict objectForKey:@"chargeDetail"]) {
                content=[self.infoDict objectForKey:@"chargeDetail"];
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

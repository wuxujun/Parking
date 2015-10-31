//
//  SearchAViewController.m
//  Parking
//
//  Created by xujunwu on 15/10/9.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import "SearchAViewController.h"
#import "UIViewController+NavigationBarButton.h"
#import "UserDefaultHelper.h"
#import "SearchHisEntity.h"
#import "DBManager.h"
#import "DBHelper.h"
#import "PoiInfoEntity.h"
#import "ListViewCell.h"
#import "SearchAView.h"

#import "SIAlertView.h"
#import "UIView+LoadingView.h"

#import "LineViewController.h"
#import "NaviViewController.h"
#import "DetailViewController.h"
#import "BListViewController.h"


@interface SearchAViewController ()<SearchAViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,ListViewCellDelegate>
{
    NSString*               currentRegion;
    NSString*               currentRegionCode;
    IFlyRecognizerView      *mIFlyRecognizerView;
    
    UIBarButtonItem         *rightButton;
    
    NSInteger               startIndex;
    NSInteger               getCount;
    

}
@property (nonatomic,strong)SearchAView*    headView;
@property (nonatomic,strong)UISearchBar*    searchBar;
@property (nonatomic,strong)UISearchDisplayController* searchController;

@end

@implementation SearchAViewController
@synthesize searchType=_searchType;
@synthesize searchKeyword=_searchKeyword;
@synthesize startPoint=_startPoint;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    startIndex=0;
    getCount=0;
    currentRegion=@"全部";
    currentRegionCode=@"0";
    self.searchBar=[[UISearchBar alloc]init];
    [self.searchBar setTintColor:[UIColor blackColor]];
    [self.searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.searchBar setPlaceholder:@"请输入关键字"];
    [self.searchBar setContentMode:UIViewContentModeLeft];
    [self.searchBar setDelegate:self];
    [self.searchBar setImage:[UIImage imageNamed:@"default_main_voice_icon_normal"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
    [self.searchBar setImage:[UIImage imageNamed:@"default_main_voice_icon_highlighted"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateHighlighted];
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,[NSValue valueWithUIOffset:UIOffsetMake(0, 1)],UITextAttributeTextShadowOffset,nil] forState:UIControlStateNormal];
    
    [self.searchBar setShowsBookmarkButton:YES];
    self.searchController=[[UISearchDisplayController alloc]initWithSearchBar:self.searchBar contentsController:self];
    [self.searchController setDelegate:self];
    [self.searchController setSearchResultsDataSource:self];
    self.navigationItem.titleView.backgroundColor=DEFAULT_NAVIGATION_BACKGROUND_COLOR;
    self.navigationItem.titleView=self.searchController.searchBar;
    
    _tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    
    [self initIFlyRecognizer];
    
    self.headView=[[SearchAView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 300) delegate:self];
    
}

-(void)initIFlyRecognizer
{
    if(mIFlyRecognizerView==nil){
        mIFlyRecognizerView=[[IFlyRecognizerView alloc] initWithCenter:CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT/2.0)];
        mIFlyRecognizerView.delegate=self;
    }
}

-(void)onVoice
{
    [self.searchBar resignFirstResponder];
    [mIFlyRecognizerView setParameter:@"domain" forKey:@"iat"];
    [mIFlyRecognizerView setParameter:@"asr_ppt" forKey:@"0"];
    [mIFlyRecognizerView setParameter:@"sample_rate" forKey:@"16000"];
    [mIFlyRecognizerView setParameter:@"vad_eos" forKey:@"500"];
    [mIFlyRecognizerView setParameter:@"vad_bos" forKey:@"2000"];
    [mIFlyRecognizerView start];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.searchBar becomeFirstResponder];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_datas count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    }
    
    NSDictionary* entity=[_datas objectAtIndex:indexPath.row];
    if (entity) {
        ListViewCell* item=[[ListViewCell alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100) delegate:self];
        item.dataType=1;
        item.infoDict=entity;
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

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if ([searchString isEqualToString:@""]) {
        return NO;
    }
//    [self search:searchString];
    return YES;
}

-(void)setCityName:(NSString*)name
{
    [rightButton setTitle:name];
    
//    UISearchBar *searchBar = self.searchBar;
//    UIView *viewTop = IOS_VERSION_7_OR_ABOVE ? searchBar.subviews[0] : searchBar;
//    NSString *classString = IOS_VERSION_7_OR_ABOVE ? @"UINavigationButton" : @"UIButton";
//    
//    for (UIView *subView in viewTop.subviews) {
//        if ([subView isKindOfClass:NSClassFromString(classString)]) {
//            UIButton *cancelButton = (UIButton*)subView;
//            //            [cancelButton setTitle:@"搜索" forState:UIControlStateNormal];
//            [cancelButton setTitle:name forState:UIControlStateNormal];
//        }
//    }
 
}

-(void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    [controller.searchBar setShowsCancelButton:YES animated:YES];
    UISearchBar *searchBar = self.searchBar;
    UIView *viewTop = IOS_VERSION_7_OR_ABOVE ? searchBar.subviews[0] : searchBar;
    NSString *classString = IOS_VERSION_7_OR_ABOVE ? @"UINavigationButton" : @"UIButton";
    
    for (UIView *subView in viewTop.subviews) {
        if ([subView isKindOfClass:NSClassFromString(classString)]) {
            UIButton *cancelButton = (UIButton*)subView;
//            [cancelButton setTitle:@"搜索" forState:UIControlStateNormal];
            [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        }
    }
    [self.searchController.searchBar setPlaceholder:@"请输入关键字"];
    [self.headView showInView:self.view];
}

-(void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [controller.searchBar setShowsCancelButton:NO animated:YES];
    [self.headView dismissMenuPopover];
}
-(void)searchBarCancelButtonClicked:(UISearchBar*)searchBar
{
    HLog(@"%@",searchBar.text);
    
//    [self onSelectCity];
}

-(void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    [self onVoice];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString* key=searchBar.text;
    self.searchBar.text=key;
//    [self.searchController.searchBar setText:searchBar.text];
    [self.searchDisplayController setActive:NO animated:NO];
    [self.searchController.searchBar setPlaceholder:key];
    [self.headView dismissMenuPopover];
    [self search:key];
}

-(void)search:(NSString*)keyword
{
    [self.view showHUDLoadingView:YES];
    [_datas removeAllObjects];
    self.searchKeyword=keyword;
    [self requestData];
}

-(void)requestData
{
    NSString* requestUrl=[NSString stringWithFormat:@"%@downgrade_service/paging_parking_list",kHttpUrl];
    NSMutableDictionary* params=[[NSMutableDictionary alloc]init];
    NSString *area=[UserDefaultHelper objectForKey:CONF_PARKING_AREA_CODE];
    if (![area isEqualToString:@"0"]) {
        [params setObject:area forKey:@"region"];
    }
    
    NSString* parkingCharge=[UserDefaultHelper objectForKey:CONF_PARKING_MAP_CHARGE];
    if (![parkingCharge isEqualToString:@"0"]) {
        [params setObject:parkingCharge forKey:@"charge"];
    }
    NSString* parkingStatus=[UserDefaultHelper objectForKey:CONF_PARKING_MAP_STATUS];
    if (![parkingStatus isEqualToString:@"0"]) {
        [params setObject:parkingStatus forKey:@"freeStatus"];
    }
    if (self.searchKeyword) {
        [params setObject:self.searchKeyword forKey:@"searchText"];
    }
    [params setObject:[NSNumber numberWithInteger:startIndex] forKey:@"startIndex"];
    [params setObject:[NSNumber numberWithInteger:getCount] forKey:@"getCount"];
    
    [self.networkEngine postOperationWithURLString:requestUrl params:params success:^(MKNetworkOperation *completedOperation, id result) {
        HLog(@"%@",result);
        [self.view showHUDLoadingView:NO];
        if([[result objectForKey:@"status"] intValue]==200){
            [self parserParkingResponse:result];
        }
    } error:^(NSError *error) {
        HLog(@"%@",error);
        [self alertRequestResult:@"网络请求发生错误,请重试!"];
        [self.view showHUDLoadingView:NO];
    }];
}

-(void)parserParkingResponse:(NSDictionary*)result
{
    
    id list=[result objectForKey:@"parkingList"];
    startIndex=[[result objectForKey:@"startIndex"] integerValue];
    NSInteger dataCount=[[result objectForKey:@"dataCount"] integerValue];
    getCount=[[result objectForKey:@"getCount"] integerValue];
    [_datas removeAllObjects];
    if ([list isKindOfClass:[NSArray class]]) {
        for (int i=0; i<[list count]; i++) {
            NSDictionary* dc=[list objectAtIndex:i];
            NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:[dc objectForKey:@"parkName"],@"title",[dc objectForKey:@"parkId"],@"poiId",[dc objectForKey:@"parkType"],@"typeDes",[dc objectForKey:@"address"],@"address",[self caclDistance:dc],@"distance",[self caclGpsValue:[dc objectForKey:@"y"] forType:0],@"latitude",[self caclGpsValue:[dc objectForKey:@"x"] forType:1],@"longitude",@"1",@"dataType",[NSString stringWithFormat:@"%d",(i+1)],@"idx",[dc objectForKey:@"charge"],@"charge",[dc objectForKey:@"chargeDetail"],@"chargeDetail",@"0",@"price",[dc objectForKey:@"totalCount"],@"totalCount",[dc objectForKey:@"freeCount"],@"freeCount",[dc objectForKey:@"freeStatus"],@"freeStatus",@"1",@"sourceType",@"0579",@"cityCode",@"330702",@"adCode",[dc objectForKey:@"shopHours"],@"shopHours",[dc objectForKey:@"thumbUrl"],@"thumbUrl",[dc objectForKey:@"parkRiveType"],@"parkRiveType", nil];
            [_datas addObject:dict];
        }
        if ([_datas count]>0) {
            [_tableView reloadData];
        }else{
            [self alertRequestResult:@"未搜索到相关数据"];
        }
    }
    if ((startIndex+getCount)<dataCount) {
        startIndex=startIndex+getCount;
        [self requestData];
    }
}

#pragma mark - 计算距离
-(NSString*)caclDistance:(NSDictionary*)dict
{
    MAMapPoint point1 = MAMapPointForCoordinate(CLLocationCoordinate2DMake([[UserDefaultHelper objectForKey:CONF_CURRENT_TARGET_LATITUDE] floatValue],[[UserDefaultHelper objectForKey:CONF_CURRENT_TARGET_LONGITUDE] floatValue]));
    MAMapPoint point2 = MAMapPointForCoordinate(CLLocationCoordinate2DMake([[self caclGpsValue:[dict objectForKey:@"y"] forType:0] floatValue],[[self caclGpsValue:[dict objectForKey:@"x"] forType:1] floatValue]));
    //计算距离
    CLLocationDistance distance = MAMetersBetweenMapPoints(point1,point2);
    NSString* distanceStr=[NSString stringWithFormat:@"%.0f",distance];
    return distanceStr;
}

-(NSString*)caclGpsValue:(NSString* )val forType:(NSInteger)type
{
    NSMutableString* newString=[[NSMutableString alloc]initWithCapacity:val.length];
    for (int i=val.length-1; i>=0; i--) {
        unichar ch=[val characterAtIndex:i];
        [newString appendFormat:@"%c",ch];
    }
    float value=0.0;
    if (type==0) {
        value=(30000000+[newString integerValue])/1000000.0;
    }else{
        value=(120000000+[newString integerValue])/1000000.0;
    }
    
    return [NSString stringWithFormat:@"%.6f",value];
}

#pragma mark - IFlyRecognizerViewDelegate
-(void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast
{
    NSMutableString *result=[[NSMutableString alloc]init];
    NSDictionary* dic=[resultArray objectAtIndex:0];
    for(NSString* key in dic){
        if ([[dic objectForKey:key] isEqualToString:@"100"]) {
            NSData *data = [key dataUsingEncoding:NSUTF8StringEncoding];
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([[json objectForKey:@"sn"] intValue]==1) {
                id ws=[json objectForKey:@"ws"];
                if ([ws isKindOfClass:[NSArray class]]) {
                    for(int i=0;i<[ws count];i++){
                        id cw=[[ws objectAtIndex:i] objectForKey:@"cw"];
                        if ([cw isKindOfClass:[NSArray class]]) {
                            for (int j=0; j<[cw count]; j++) {
                                [result appendFormat:@"%@",[[cw objectAtIndex:j] objectForKey:@"w"]];
                            }
                        }
                    }
                }
                [mIFlyRecognizerView cancel];
                self.searchBar.text=[NSString stringWithFormat:@"%@",result];
            }
        }
    }
    HLog(@"%@",result);
}

-(void)onError:(IFlySpeechError *)error
{
    
}
@end

//
//  SearchViewController.m
//  Parking
//
//  Created by xujunwu on 15/8/31.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "SearchViewController.h"
#import "UIViewController+NavigationBarButton.h"
#import "SearchHeadView.h"
#import "SearchMapViewController.h"
#import "DBManager.h"
#import "DBHelper.h"
#import "SearchHisEntity.h"
#import "MoreViewController.h"


@interface SearchViewController()<UISearchDisplayDelegate,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,SearchHeadViewDelegate>
{
    IFlyRecognizerView      *mIFlyRecognizerView;
}
@property (nonatomic,strong)UISearchBar*    searchBar;
@property (nonatomic,strong)UISearchDisplayController* searchController;
@property (nonatomic,strong)SearchHeadView* searchHead;

@end

@implementation SearchViewController
@synthesize searchType=_searchType;
@synthesize searchKeyword=_searchKeyword;
@synthesize startPoint=_startPoint;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.searchBar=[[UISearchBar alloc]init];
    [self.searchBar setTintColor:[UIColor blackColor]];
    [self.searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.searchBar setPlaceholder:@"请输入目的地"];
    [self.searchBar setDelegate:self];
    [self.searchBar setImage:[UIImage imageNamed:@"default_main_voice_icon_normal"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
    [self.searchBar setImage:[UIImage imageNamed:@"default_main_voice_icon_highlighted"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateHighlighted];
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,[NSValue valueWithUIOffset:UIOffsetMake(0, 1)],UITextAttributeTextShadowOffset,nil] forState:UIControlStateNormal];
    
    for (UIView *view in self.searchBar.subviews) {
        // for before iOS7.0
        if ([view isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [view removeFromSuperview];
            break;
        }
        // for later iOS7.0(include)
        if ([view isKindOfClass:NSClassFromString(@"UIView")] && view.subviews.count > 0) {
            [[view.subviews objectAtIndex:0] removeFromSuperview];
            break;
        }
    }
    
    [self.searchBar setShowsBookmarkButton:YES];
    self.searchController=[[UISearchDisplayController alloc]initWithSearchBar:self.searchBar contentsController:self];
    [self.searchController setDelegate:self];
    [self.searchController setSearchResultsDataSource:self];
    self.navigationItem.titleView=self.searchController.searchBar;

    _tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    
    [self initSearch];
    [self initIFlyRecognizer];
}

-(void)initIFlyRecognizer
{
    if(mIFlyRecognizerView==nil){
        mIFlyRecognizerView=[[IFlyRecognizerView alloc] initWithCenter:CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT/2.0)];
        mIFlyRecognizerView.delegate=self;
    }
}


-(void)onSearch
{
    NSString* key=self.searchBar.text;
    if (key.length==0) {
        [self alertRequestResult:@"请输入搜索关键字"];
        return;
    }
//    SearchMapViewController* dController=[[SearchMapViewController alloc]init];
//    dController.searchKeyword=self.searchBar.text;
//    dController.startPoint=self.startPoint;
//    dController.cityCode=self.cityCode;
//    [self.navigationController pushViewController:dController animated:YES];
    
    NSDictionary* dict=[NSDictionary dictionaryWithObjectsAndKeys:self.searchBar.text,@"title",@"4",@"dataType",[NSString stringWithFormat:@"%@",self.cityCode],@"cityCode", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SEARCH_KEYWORK object:dict];
    [self.navigationController popViewControllerAnimated:YES];
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

-(void)initSearch
{
    self.searchAPI=[[AMapSearchAPI alloc] initWithSearchKey:AMAP_KEY Delegate:self];
    
    if (self.searchHead==nil) {
        self.searchHead=[[SearchHeadView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 125) delegate:self];
        
    }
    if (_tableView) {
        [_tableView setTableHeaderView:self.searchHead];
    }
}

-(void)initHistoryData
{
    [_datas removeAllObjects];
    NSArray* array=[[DBManager getInstance] querySearchHistory];
    self.dataType=1;
    [_datas addObjectsFromArray:array];
    [_tableView reloadData];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.searchType==1){
        self.searchBar.text=self.searchKeyword;
    }else{
        [self.searchBar becomeFirstResponder];
    }
    [self initHistoryData];
}

-(void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response
{
    if ([response.tips count]>0) {
        [_datas setArray:response.tips];
        if ([_datas count]>0) {
            [_tableView setTableHeaderView:nil];
        }
        self.dataType=0;
        [_tableView reloadData];
    }
}

-(void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)response
{
    [_datas removeAllObjects];
    if ([response.pois count]>0) {
        [_datas setArray:response.pois];
        if ([_datas count]>0) {
            [_tableView setTableHeaderView:nil];
        }
        self.dataType=0;
        [_tableView reloadData];
    }
}

-(void)searchRequest:(id)request didFailWithError:(NSError *)error
{
    HLog(@"%@  %@",[request class],error);
}

-(void)searchTipsWithKey:(NSString*)strKey
{
    if (strKey.length==0) {
        return;
    }
//    AMapInputTipsSearchRequest  *tips=[[AMapInputTipsSearchRequest alloc]init];
//    tips.keywords=strKey;
//    [self.searchAPI AMapInputTipsSearch:tips];
    AMapPlaceSearchRequest * poiRequest=[[AMapPlaceSearchRequest alloc]init];
    poiRequest.searchType=AMapSearchType_PlaceKeyword;
    poiRequest.sortrule=1;
    poiRequest.offset=10;
    poiRequest.keywords=strKey;
    if(self.cityCode){
        poiRequest.city=@[self.cityCode];
    }
    poiRequest.requireExtension=YES;
    [self.searchAPI AMapPlaceSearch:poiRequest];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.dataType==1) {
        return 2;
    }
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataType==1) {
        if (section==1) {
            return 1;
        }
    }
    return [_datas count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataType==1) {
        return 44.0;
    }
    return 64.0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    }
    if (self.dataType==1) {
        if (indexPath.section==1) {
            
            UILabel* lb=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
            if ([_datas count]>0) {
                [lb setText:@"清除历史记录"];
            }else{
                [lb setText:@"您还没有历史记录"];
            }
            [lb setFont:[UIFont systemFontOfSize:14.0f]];
            [lb setTextColor:DEFAULT_FONT_COLOR];
            [lb setTextAlignment:NSTextAlignmentCenter];
            [cell addSubview:lb];
        }else{
            SearchHisEntity* entity=[_datas objectAtIndex:indexPath.row];
            if (entity) {
                [cell.imageView setImage:[UIImage imageNamed:@"default_main_search_icon_normal"]];
                cell.textLabel.text=entity.keyword;
            }
        }
    }else{
//        AMapTip  *tip=[_datas objectAtIndex:indexPath.row];
        AMapPOI* poi=[_datas objectAtIndex:indexPath.row];
        UIImageView * icon=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"default_generalsearch_sugg_tqueryicon_normal"]];
        [icon setFrame:CGRectMake(10, (64-30)/2, 30, 30)];
        [cell addSubview:icon];
        
        
        UILabel* lb=[[UILabel alloc]initWithFrame:CGRectMake(50, 10, SCREEN_WIDTH-50, 30)];
        [lb setText:poi.name];
        [lb setFont:[UIFont systemFontOfSize:16.0f]];
        [lb setTextColor:DEFAULT_FONT_COLOR];
        [lb setTextAlignment:NSTextAlignmentLeft];
        [cell addSubview:lb];
        
        UILabel* address=[[UILabel alloc]initWithFrame:CGRectMake(50, 32, SCREEN_WIDTH-50, 30)];
        [address setText:poi.address];
        [address setFont:[UIFont systemFontOfSize:12.0f]];
        [address setTextColor:[UIColor grayColor]];
        [address setTextAlignment:NSTextAlignmentLeft];
        [cell addSubview:address];
        
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.searchBar resignFirstResponder];
    if (self.dataType==1) {
        if (indexPath.section==1) {
            if ([_datas count]>0) {
                [[DBManager getInstance] deleteSearchHistory];
                [self initHistoryData];
            }
        }else{
            SearchHisEntity* entity=[_datas objectAtIndex:indexPath.row];
            if (entity) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SEARCH_HIS_KEYWORK object:entity];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }else{
//        AMapTip  *tip=[_datas objectAtIndex:indexPath.row];
        AMapPOI *poi=[_datas objectAtIndex:indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SEARCH_TIP object:poi];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if ([searchString isEqualToString:@""]) {
        return NO;
    }
    [self searchTipsWithKey:searchString];
    return YES;
}

-(void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    [controller.searchBar setShowsCancelButton:YES animated:YES];
    
    UISearchBar *searchBar = self.searchDisplayController.searchBar;
    UIView *viewTop = IOS_VERSION_7_OR_ABOVE ? searchBar.subviews[0] : searchBar;
    NSString *classString = IOS_VERSION_7_OR_ABOVE ? @"UINavigationButton" : @"UIButton";
    
    for (UIView *subView in viewTop.subviews) {
        if ([subView isKindOfClass:NSClassFromString(classString)]) {
            UIButton *cancelButton = (UIButton*)subView;
            [cancelButton setTitle:@"搜索" forState:UIControlStateNormal];
//            [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        }
    }
}

-(void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [controller.searchBar setShowsCancelButton:NO animated:YES];
}
-(void)searchBarCancelButtonClicked:(UISearchBar*)searchBar
{
    HLog(@"%@",searchBar.text);
    
    [self onSearch];
}

-(void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    [self onVoice];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString* key=searchBar.text;
    self.searchBar.text=key;
//    [self.searchDisplayController setActive:NO animated:NO];
//    self.searchBar.placeholder=key;
//    [self searchTipsWithKey:key];
    [self onSearch];
}

#pragma mark - SearchHeadViewDelegate
-(void)onSearchHeadViewClicked:(NSString *)keyworkd
{
    NSString* type=@"0";
    if ([keyworkd isEqualToString:@"停车场"]) {
        type=@"1";
    }else if ([keyworkd isEqualToString:@"公交站"]) {
        type=@"3";
    }else if([keyworkd isEqualToString:@"公共自行车"]){
        type=@"2";
    }
    
    if (self.searchType==2) {
//        NSDictionary* dict=[NSDictionary dictionaryWithObjectsAndKeys:keyworkd,@"title",type,@"dataType", nil];
        NSMutableDictionary* dict=[[NSMutableDictionary alloc]initWithDictionary:self.startPoint];
        [dict setObject:type forKey:@"dataType"];
        [dict setObject:keyworkd forKey:@"keyword"];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SEARCH_NEARBY_KEYWORK object:dict];
    }else{
        NSDictionary* dict=[NSDictionary dictionaryWithObjectsAndKeys:keyworkd,@"title",type,@"dataType", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SEARCH_KEYWORK object:dict];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onSearchHeadViewMore:(SearchHeadView *)view
{
    MoreViewController* dController=[[MoreViewController alloc]init];
    [self.navigationController pushViewController:dController animated:YES];
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

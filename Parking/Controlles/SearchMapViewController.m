//
//  SearchMapViewController.m
//  Parking
//
//  Created by xujunwu on 15/9/21.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import "SearchMapViewController.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import <QuartzCore/QuartzCore.h>
#import "UserDefaultHelper.h"
#import "HomeInfoView.h"
#import "POIAnnotation.h"
#import "StringUtil.h"
#import "ListViewCell.h"
#import "LineViewController.h"
#import "NaviViewController.h"
#import "DetailViewController.h"
#import "BListViewController.h"



@interface SearchMapViewController ()<UISearchDisplayDelegate,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,ListViewCellDelegate>
{
    IFlyRecognizerView      *mIFlyRecognizerView;
    
    NSMutableArray          *data;
    
    UITableView             *mTableView;
    
    UIView          * mFooterView;
    UIScrollView    * mFooterScrollView;
    
    UIBarButtonItem         *rightButton;
    BOOL                    bShowMap;
    
}

@property (nonatomic,strong)UISearchBar*    searchBar;
@property (nonatomic,strong)UISearchDisplayController* searchController;

@end

@implementation SearchMapViewController
@synthesize searchType=_searchType;
@synthesize searchKeyword=_searchKeyword;
@synthesize startPoint=_startPoint;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    data=[[NSMutableArray alloc] init];
    bShowMap=YES;
    
    if(mTableView==nil){
        mTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64) style:UITableViewStylePlain];
        mTableView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        mTableView.delegate=self;
        mTableView.dataSource=self;
        mTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
        [self.view addSubview:mTableView];
    }
    rightButton=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"default_common_list_icon_normal"] style:UIBarButtonItemStylePlain target:self action:@selector(onShowList:)];
    
    self.searchBar=[[UISearchBar alloc]init];
    [self.searchBar setTintColor:[UIColor blackColor]];
    [self.searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.searchBar setImage:[UIImage imageNamed:@"default_main_voice_icon_highlighted"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateHighlighted];
    [self.searchBar setImage:[UIImage imageNamed:@"default_main_voice_icon_normal"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
    [self.searchBar setShowsBookmarkButton:YES];
    
    [self.searchBar setPlaceholder:@"请输入目的地"];
    [self.searchBar setDelegate:self];
    
    self.searchController=[[UISearchDisplayController alloc]initWithSearchBar:self.searchBar contentsController:self];
    [self.searchController setDelegate:self];
    [self.searchController setSearchResultsDataSource:self];
    self.navigationItem.titleView=self.searchController.searchBar;
    
    [self initSearch];
    [self initIFlyRecognizer];
    
    [self initFooterView];
    [self configMapView];
}

-(void)configMapView
{
    self.mapView.delegate = self;
    
    self.mapView.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view insertSubview:self.mapView atIndex:0];
    self.mapView.showsUserLocation = YES;
}

-(void)initIFlyRecognizer
{
    if(mIFlyRecognizerView==nil){
        mIFlyRecognizerView=[[IFlyRecognizerView alloc] initWithCenter:CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT/2.0)];
        mIFlyRecognizerView.delegate=self;
    }
}

-(void)initFooterView
{
    if (mFooterView==nil) {
        mFooterView=[[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-120, self.view.frame.size.width, 100.0)];
        [self.view  addSubview:mFooterView];
    }
    
    if (mFooterScrollView==nil) {
        mFooterScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100.0)];
        mFooterScrollView.pagingEnabled=YES;
        mFooterScrollView.delegate=self;
        mFooterScrollView.showsVerticalScrollIndicator=NO;
        mFooterScrollView.showsHorizontalScrollIndicator=NO;
        [mFooterView addSubview:mFooterScrollView];
    }
}
-(void)initSearch
{
    self.searchAPI=[[AMapSearchAPI alloc] initWithSearchKey:AMAP_KEY Delegate:self];
}

-(void)searchForKeyword
{
    [data removeAllObjects];
    AMapPlaceSearchRequest * poiRequest=[[AMapPlaceSearchRequest alloc]init];
    poiRequest.searchType=AMapSearchType_PlaceKeyword;
    poiRequest.sortrule=1;
    poiRequest.offset=10;
    poiRequest.keywords=self.searchKeyword;
    poiRequest.city=@[self.cityCode];
    poiRequest.requireExtension=YES;
    [self.searchAPI AMapPlaceSearch:poiRequest];
}

-(IBAction)onShowList:(id)sender
{
    if (bShowMap) {
        [self.view sendSubviewToBack:self.mapView];
        [self.view sendSubviewToBack:mFooterView];
        [rightButton setImage:[UIImage imageNamed:@"default_common_map_icon_normal"]];
        
        [mTableView reloadData];
    }else{
        [self.view sendSubviewToBack:mTableView];
        [rightButton setImage:[UIImage imageNamed:@"default_common_list_icon_normal"]];
        [self.view bringSubviewToFront:mFooterView];
    }
    bShowMap=!bShowMap;
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
    if (self.searchKeyword) {
        self.searchBar.text=self.searchKeyword;
        [self searchForKeyword];
    }
    [self.view sendSubviewToBack:mTableView];
    if (mFooterView) {
        [self.view bringSubviewToFront:mFooterView];
    }
}

-(void)reloadFooterData
{
    for (UIView* view in mFooterScrollView.subviews) {
        if ([view isKindOfClass:[HomeInfoView class]]) {
            [view removeFromSuperview];
        }
    }
    HomeInfoView* item;
    for (int i=0; i<[data count]; i++) {
        item=[[HomeInfoView alloc]initWithFrame:CGRectMake(i*self.view.frame.size.width, 0, self.view.frame.size.width, 100) delegate:self];
        [item setInfoDict:[data objectAtIndex:i]];
        [mFooterScrollView addSubview:item];
    }
    mFooterScrollView.contentSize=CGSizeMake(mFooterScrollView.frame.size.width*[data count], mFooterScrollView.frame.size.height);
    [mFooterScrollView scrollRectToVisible:CGRectMake(0, 0, mFooterScrollView.frame.size.width, mFooterScrollView.frame.size.height) animated:YES];
    if ([data count]>0) {
        self.navigationItem.rightBarButtonItem=rightButton;
        
    }else{
        self.navigationItem.rightBarButtonItem=nil;
    }
    [self.view sendSubviewToBack:mTableView];
}


-(void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response
{
    if ([response.tips count]>0) {
//        [datas setArray:response.tips];
//        if ([_datas count]>0) {
//            [_tableView setTableHeaderView:nil];
//        }
//        [_tableView reloadData];
    }
}

-(void)searchRequest:(id)request didFailWithError:(NSError *)error
{
    HLog(@"%@  %@",[request class],error);
}

-(void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)response
{
    if (response.pois.count==0) {
        return;
    }
    [data removeAllObjects];
    NSMutableArray* poiAnnotations=[NSMutableArray arrayWithCapacity:response.pois.count];
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI* p,NSUInteger idx,BOOL *stop){
        
        NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:p.name,@"title",p.uid,@"uid",p.type,@"type",p.address,@"address",[NSString stringWithFormat:@"%@",[NSString caleDistance:p.distance]],@"distance",[NSString stringWithFormat:@"%f",p.location.latitude],@"latitude",[NSString stringWithFormat:@"%f",p.location.longitude],@"longitude",@"0",@"dataType",[NSString stringWithFormat:@"%ld",(idx+1)],@"index",@"无",@"price",@"0",@"dataType", nil];
        [data addObject:dict];
            //            HLog(@"%@",dict);
        [poiAnnotations addObject:[[POIAnnotation alloc] initWithPOI:p index:idx isSelected:NO]];
        
    }];
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView addAnnotations:poiAnnotations];
    if (poiAnnotations.count==1) {
        self.mapView.centerCoordinate=[(POIAnnotation*)poiAnnotations[0] coordinate];
    }else{
        [self.mapView showAnnotations:poiAnnotations animated:YES];
    }
    [self reloadFooterData];
}

-(void)searchTipsWithKey:(NSString*)strKey
{
    if (strKey.length==0) {
        return;
    }
    AMapInputTipsSearchRequest  *tips=[[AMapInputTipsSearchRequest alloc]init];
    tips.keywords=strKey;
    [self.searchAPI AMapInputTipsSearch:tips];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0f;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [data count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    NSDictionary* dict=[data objectAtIndex:indexPath.row];
    if (dict) {
        ListViewCell* item=[[ListViewCell alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100) delegate:self];
        item.dataType=0;
        item.infoDict=dict;
        [cell addSubview:item];
    }
    cell.accessoryType=UITableViewCellAccessoryNone;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [self.searchBar resignFirstResponder];
//    AMapTip  *tip=[data objectAtIndex:indexPath.row];
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SEARCH_TIP object:tip];
//    [self.navigationController popViewControllerAnimated:YES];
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
//    [controller.searchBar setShowsCancelButton:YES animated:YES];
//    UISearchBar *searchBar = self.searchDisplayController.searchBar;
//    UIView *viewTop = IOS_VERSION_7_OR_ABOVE ? searchBar.subviews[0] : searchBar;
//    NSString *classString = IOS_VERSION_7_OR_ABOVE ? @"UINavigationButton" : @"UIButton";
//    
//    for (UIView *subView in viewTop.subviews) {
//        if ([subView isKindOfClass:NSClassFromString(classString)]) {
//            UIButton *cancelButton = (UIButton*)subView;
//            [cancelButton setTitle:@"搜索" forState:UIControlStateNormal];
//        }
//    }
//    self.navigationItem.rightBarButtonItem=nil;
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [controller.searchBar setShowsCancelButton:NO animated:YES];
}
-(void)searchBarCancelButtonClicked:(UISearchBar*)searchBar
{
    HLog(@"%@",searchBar.text);
    NSString* key=self.searchBar.text;
    if (key.length==0) {
        [self alertRequestResult:@"请输入搜索关键字"];
        return;
    }
    self.searchKeyword=key;
    [self searchForKeyword];
}

-(void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    [self onVoice];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString* key=searchBar.text;
    [self.searchDisplayController setActive:NO animated:NO];
//    self.searchBar.placeholder=key;
//    [self searchTipsWithKey:key];
    self.searchKeyword=key;
    [self searchForKeyword];
}

#pragma mark - SearchHeadViewDelegate
-(void)onSearchHeadViewClicked:(NSString *)keyworkd
{
    NSString* type=@"1";
    if ([keyworkd isEqualToString:@"公交站"]) {
        type=@"3";
    }else if([keyworkd isEqualToString:@"公共自行车"]){
        type=@"2";
    }
    
    NSDictionary* dict=[NSDictionary dictionaryWithObjectsAndKeys:keyworkd,@"title",type,@"dataType", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SEARCH_KEYWORK object:dict];
    
    [self.navigationController popViewControllerAnimated:YES];
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

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    //    CGFloat pageWidth=mFooterScrollView.frame.size.width;
    //    int page=floor((mFooterScrollView.contentOffset.x-pageWidth/2)/pageWidth)+1;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth=mFooterScrollView.frame.size.width;
    int page=floor((mFooterScrollView.contentOffset.x-pageWidth/2)/pageWidth)+1;
    if (page<[data count]) {
        NSDictionary* dic=[data objectAtIndex:page];
        [self selectPOIAnnotationForIndex:page];
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake([[dic objectForKey:@"latitude"] floatValue], [[dic objectForKey:@"longitude"] floatValue]) animated:YES];
    }
    
}

-(void)selectPOIAnnotationForIndex:(NSInteger)idx
{
    NSArray* array=self.mapView.annotations;
    for ( int i=0;i<[array count];i++) {
        id <MAAnnotation> an=[array objectAtIndex:i];
        if ([an isKindOfClass:[POIAnnotation class]]) {
            if ([(POIAnnotation*)an index]==idx) {
                POIAnnotation *poi=[[POIAnnotation alloc]initWithPOI:[(POIAnnotation*)an poi] index:idx isSelected:YES];
                [self.mapView removeAnnotation:an];
                [self.mapView addAnnotation:poi];
            }else{
                POIAnnotation *poi=[[POIAnnotation alloc]initWithPOI:[(POIAnnotation*)an poi] index:[(POIAnnotation*)an index] isSelected:NO];
                [self.mapView removeAnnotation:an];
                [self.mapView addAnnotation:poi];
            }
        }
    }
}

-(void)onListViewCellClicked:(ListViewCell*)view forIndex:(int)idx
{
    switch (idx) {
        case 0:
        {
            break;
        }
        case 1:
        {
            LineViewController* dController=[[LineViewController alloc]init];
            dController.lineType=0;
            [dController setStartPoint:self.startPoint];
            [dController setEndPoint:view.infoDict];
            [self.navigationController pushViewController:dController animated:YES];
        }
            break;
        case 2:
        {
            NaviViewController* dController=[[NaviViewController alloc]init];
            [dController setNaviType:0];
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

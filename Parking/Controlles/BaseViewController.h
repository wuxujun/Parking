//
//  BaseViewController.h
//  Woicar
//
//  Created by xujun wu on 13-5-26.
//  Copyright (c) 2013年 xujun wu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PullRefreshViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"


@interface BaseViewController : PullRefreshViewController<EGORefreshTableHeaderDelegate>
{
    MBProgressHUD           *loading;
    
    NSString                *categoryId;
    UIBarButtonItem         *queryBtn;
    
    NSMutableArray          *_datas;
    
    EGORefreshTableHeaderView       *_refreshHeaderView;
    BOOL                            _reloading;
    
    BOOL                            _loadingOver;
    long long                       _maxID;
    int                             _page;
    
    int                             _rownums;
    int                             _pageSize;
    BOOL                            _shouldAppendDataArr;

}

@property (nonatomic,strong)NSDictionary         *infoDict;
@property (nonatomic,strong)NSString             *categoryId;


-(void)setBarButton;

-(void)reloadData;
-(void)reloadData:(NSString*)message;

-(void)refreshData;
-(void)clear;
-(void)reload:(BOOL)flag;

-(void)tips;


-(void)alertRequestResult:(NSString*)message;
-(void)loadData:(NSNotification*)sender;
-(void)requestFailed:(NSNotification*)sender;
-(void)parserData:(NSDictionary*)aDict userInfo:(NSDictionary*)aUserInfo;

-(void)reloadTableViewDataSource;
-(void)doneLoadingTableViewData;


@end

//
//  BViewController.h
//  Woicar
//
//  Created by xujunwu on 14-5-4.
//  Copyright (c) 2014年 xujun wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HNetworkEngine.h"
#import "MBProgressHUD.h"

@interface BViewController : UIViewController
{
    NSMutableArray              *_datas;
    UITableView                 *_tableView;
    MBProgressHUD               *loading;
}

@property(nonatomic,strong)HNetworkEngine       *networkEngine;
@property (nonatomic,strong)NSDictionary        *infoDict;
@property (nonatomic,assign)NSInteger           dataType;
@property(nonatomic,strong)NSString*            cityCode;

-(void)reloadData;
-(void)reloadData:(NSString*)message;
-(void)loadData:(NSNotification*)sender;
-(void)requestFailed:(NSNotification*)sender;

-(void)alertRequestResult:(NSString*)message;

@end

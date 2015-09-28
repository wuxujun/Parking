//
//  IViewController.h
//  Parking
//
//  Created by xujunwu on 15/9/17.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface IViewController : UIViewController
{
    NSMutableArray              *_datas;
    UITableView                 *_tableView;
    MBProgressHUD               *loading;
}

@property (nonatomic,strong)NSDictionary    *infoDict;
@property (nonatomic,assign)int                dataType;

-(void)reloadData;
-(void)reloadData:(NSString*)message;
-(void)loadData:(NSNotification*)sender;
-(void)requestFailed:(NSNotification*)sender;

-(void)alertRequestResult:(NSString*)message;

@end

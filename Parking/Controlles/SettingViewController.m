//
//  SettingViewController.m
//  CateringM
//
//  Created by xujunwu on 14-7-4.
//  Copyright (c) 2014年 ___Hongkui___. All rights reserved.
//

#import "SettingViewController.h"
#import "UIViewController+NavigationBarButton.h"
#import "UserDefaultHelper.h"
#import "SettingMViewController.h"

@interface SettingViewController ()

@property(nonatomic,strong)UILabel*    voiceTypeLabel;

@end

@implementation SettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setCenterTitle:@"设置"];
    _tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)loadData
{
    NSData *jsdata = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"setting" ofType:@"json"]];
    
    @autoreleasepool {
        
        if (jsdata)
        {
            NSArray *dicArray = [NSJSONSerialization JSONObjectWithData:jsdata options:NSJSONReadingAllowFragments error:nil];
            
            for (NSDictionary *dic in dicArray)
            {
                [_datas addObject:dic];
            }
            [_tableView reloadData];
        }
    }
    
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.0;
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
    NSDictionary* dict=[_datas objectAtIndex:indexPath.row];
    if (dict) {
        cell.textLabel.text=[dict objectForKey:@"title"];
        int type=[[dict objectForKey:@"type"] intValue];
        if (type==0) {
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        }else{
            BOOL isval=[[UserDefaultHelper objectForKey:[dict objectForKey:@"valueKey"]] boolValue];
            UISwitch *sw=[[UISwitch alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-60, 10, 60, 30)];
            [sw setOn:isval];
            sw.tag=indexPath.row;
            [sw addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:sw];
            if (type==2) {
                if (self.voiceTypeLabel==nil) {
                    self.voiceTypeLabel=[[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-80, 12, 20, 30)];
                    [self.voiceTypeLabel setFont:[UIFont systemFontOfSize:14.0f]];
                    if (isval) {
                        [self.voiceTypeLabel setText:@"男"];
                    }else{
                        [self.voiceTypeLabel setText:@"女"];
                    }
                    [cell addSubview:self.voiceTypeLabel];
                }
            }

            cell.accessoryType=UITableViewCellAccessoryNone;
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        }
    }

    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    NSDictionary* dict=[_datas objectAtIndex:indexPath.row];
    if (dict) {
        int type=[[dict objectForKey:@"type"] intValue];
        if (type==0) {
            SettingMViewController* dController=[[SettingMViewController alloc]init];
            dController.dataType=[[dict objectForKey:@"valueKey"] integerValue];
            [self.navigationController pushViewController:dController animated:YES];
        }
    }
}

-(IBAction)onSwitch:(id)sender
{
    UISwitch* sw=(UISwitch*)sender;
    NSDictionary* dict=[_datas objectAtIndex:sw.tag];
    if (dict) {
        [UserDefaultHelper setObject:[NSNumber numberWithBool:sw.isOn] forKey:[dict objectForKey:@"valueKey"]];
        int type=[[dict objectForKey:@"type"] intValue];
        if (type==2) {
            if (sw.on) {
                [self.voiceTypeLabel setText:@"男"];
            }else{
                [self.voiceTypeLabel setText:@"女"];
            }
        }
    }
}
@end

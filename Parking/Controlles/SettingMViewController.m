//
//  SettingMViewController.m
//  Parking
//
//  Created by xujunwu on 15/9/17.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import "SettingMViewController.h"
#import "UIViewController+NavigationBarButton.h"
#import "UserDefaultHelper.h"

@interface SettingMViewController ()

@property(nonatomic,strong)UILabel*    voiceTypeLabel;

@end

@implementation SettingMViewController
@synthesize dataType=_dataType;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setCenterTitle:@"地图设置"];
    if (self.dataType==2) {
        [self setCenterTitle:@"导航设置"];
    }
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
    NSString* fileName=@"setting_map";
    if (self.dataType==2) {
        fileName=@"setting_navi";
    }
    NSData *jsdata = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"json"]];
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
    NSDictionary* dict=[_datas objectAtIndex:indexPath.row];
    if (dict) {
        int type=[[dict objectForKey:@"type"] intValue];
        if (type==3) {
            return 100.0;
        }
    }
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
        int type=[[dict objectForKey:@"type"] intValue];
        if (type==3) {
            UILabel* lb=[[UILabel alloc]initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH-20, 30)];
            [lb setText:[dict objectForKey:@"title"]];
            [cell addSubview:lb];
            id ds=[dict objectForKey:@"datas"];
            if ([ds isKindOfClass:[NSArray class]]) {
                float w=(SCREEN_WIDTH-40)/3.0;
                for (int i=0; i<[ds count]; i++) {
                    NSDictionary* dc=[ds objectAtIndex:i];
                    HLog(@"%@",dc);
                    UIButton* btn=[[UIButton alloc]initWithFrame:CGRectMake(10+w*i+10*i, 44, w, 32)];
                    btn.tag=[[dc objectForKey:@"id"] integerValue];
                    [btn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
                    [btn setTitleColor:DEFAULT_FONT_COLOR forState:UIControlStateNormal];
                    [btn setTitle:[dc objectForKey:@"title"] forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
                    [btn.layer setBorderWidth:0.5];
                    [btn.layer setMasksToBounds:YES];
                    [btn.layer setCornerRadius:4.0f];
                    
                    UIImageView* iv=[[UIImageView alloc]initWithFrame:CGRectMake(w-8, 32-8, 8, 8)];
                    [iv setTag:100];
                    [iv setImage:[UIImage imageNamed:@"default_common_checkbutton_icon_highlighted@3x"]];
                    [btn addSubview:iv];
                    
                    if ([self getPreValue:[dc objectForKey:@"valueKey"]]) {
                        [iv setHidden:NO];
                        [btn.layer setBorderColor:[DEFAULT_NAVIGATION_BACKGROUND_COLOR CGColor]];
                    }else{
                        [iv setHidden:YES];
                        [btn.layer setBorderColor:[DEFAULT_LINE_COLOR CGColor]];
                    }
                    
                    [cell addSubview:btn];
                }
            }
            
        }else{
            cell.textLabel.text=[dict objectForKey:@"title"];
            BOOL isval=[[UserDefaultHelper objectForKey:[dict objectForKey:@"valueKey"]] boolValue];
            UISwitch *sw=[[UISwitch alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-60, 10, 60, 30)];
            [sw setOn:isval];
            sw.tag=indexPath.row;
            [sw addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:sw];

            cell.accessoryType=UITableViewCellAccessoryNone;
        }
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(BOOL)getPreValue:(NSString*)val
{
    BOOL isVal=[[UserDefaultHelper objectForKey:val] boolValue];
    return isVal;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(IBAction)onButton:(id)sender
{
    UIButton* btn=(UIButton*)sender;
    UIImageView* iv;
    for (UIView* view in btn.subviews) {
        if ([view isKindOfClass:[UIImageView class]]&&view.tag==100) {
            iv=(UIImageView*)view;
        }
    }
    
    switch (btn.tag) {
        case 1:
        {
            BOOL isVal=[[UserDefaultHelper objectForKey:PRE_NAVI_MODE_JAM] boolValue];
            [UserDefaultHelper setObject:[NSNumber numberWithBool:!isVal] forKey:PRE_NAVI_MODE_JAM];
            if (isVal) {
                [btn.layer setBorderColor:[DEFAULT_LINE_COLOR CGColor]];
                [iv setHidden:YES];
            }else{
                [btn.layer setBorderColor:[DEFAULT_NAVIGATION_BACKGROUND_COLOR CGColor]];
                [iv setHidden:NO];
            }
        }
            break;
        case 2:
        {
            BOOL isVal=[[UserDefaultHelper objectForKey:PRE_NAVI_MODE_HIGHWAY] boolValue];
            [UserDefaultHelper setObject:[NSNumber numberWithBool:!isVal] forKey:PRE_NAVI_MODE_HIGHWAY];
            if (isVal) {
                [btn.layer setBorderColor:[DEFAULT_LINE_COLOR CGColor]];
                [iv setHidden:YES];
            }else{
                [btn.layer setBorderColor:[DEFAULT_NAVIGATION_BACKGROUND_COLOR CGColor]];
                [iv setHidden:NO];
            }
        }
            break;
    
        case 3:
        {
            BOOL isVal=[[UserDefaultHelper objectForKey:PRE_NAVI_MODE_CHARGE] boolValue];
            [UserDefaultHelper setObject:[NSNumber numberWithBool:!isVal] forKey:PRE_NAVI_MODE_CHARGE];
            if (isVal) {
                [btn.layer setBorderColor:[DEFAULT_LINE_COLOR CGColor]];
                [iv setHidden:YES];
            }else{
                [btn.layer setBorderColor:[DEFAULT_NAVIGATION_BACKGROUND_COLOR CGColor]];
                [iv setHidden:NO];
            }
        }
            break;
            
        default:
            break;
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

//
//  MoreViewController.m
//  Parking
//
//  Created by xujunwu on 15/10/19.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import "MoreViewController.h"
#import "UIViewController+NavigationBarButton.h"

@interface MoreViewController ()

@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setCenterTitle:@"更多"];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadData
{
    NSString* fileName=@"search_more";
    
    NSData *jsdata = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"json"]];
    @autoreleasepool {
        if (jsdata)
        {
            NSArray *dicArray = [NSJSONSerialization JSONObjectWithData:jsdata options:NSJSONReadingAllowFragments error:nil];
            for (NSDictionary *dic in dicArray)
            {
                [_datas addObject:dic];
            }
        }
    }
    [_tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadData];
}

-(IBAction)onButton:(id)sender
{
    UIButton* btn=(UIButton*)sender;
    NSString* keyword=btn.titleLabel.text;
    [self.navigationController popToRootViewControllerAnimated:YES];
    NSDictionary* dict=[NSDictionary dictionaryWithObjectsAndKeys:keyword,@"title",@"0",@"dataType", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SEARCH_KEYWORK object:dict];
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* dict=[_datas objectAtIndex:indexPath.row];
    return [[dict objectForKey:@"height"] floatValue];
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
    
    UIView* bgView=[[UIView alloc]initWithFrame:CGRectMake(5, 5, SCREEN_WIDTH-10, [[dict objectForKey:@"height"] floatValue]-10.0)];
    bgView.backgroundColor=[UIColor whiteColor];
    bgView.layer.borderWidth=0.5;
    bgView.layer.cornerRadius=5.0;
    bgView.layer.masksToBounds=YES;
    bgView.layer.borderColor=[DEFAULT_LINE_COLOR CGColor];
    [cell addSubview:bgView];
    UILabel* lb=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [lb setText:[dict objectForKey:@"title"]];
    [lb setTextAlignment:NSTextAlignmentCenter];
    [lb setFont:[UIFont boldSystemFontOfSize:20.0f]];
    [bgView addSubview:lb];
    if (dict) {
        id ds=[dict objectForKey:@"datas"];
        if ([ds isKindOfClass:[NSArray class]]) {
            int count=[ds count];
            float w=(SCREEN_WIDTH-60)/3.0;
            float y=4.0;
            int row=-1;
            int col=0;
            for (int i=0; i<count; i++) {
                HLog(@"---->%d   %d   %d",i%3,row,col);
                if (i%3==0) {
                    row++;
                    col=0;
                }
                NSDictionary * dc=[ds objectAtIndex:i];
                UIButton* btn=[[UIButton alloc] initWithFrame:CGRectMake(40+w*col+5*col, 5+44*row, w, 44)];
                btn.tag=[[dc objectForKey:@"id"] integerValue];
                [btn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
                [btn.titleLabel setTextAlignment:NSTextAlignmentCenter];
                [btn setTitleColor:DEFAULT_FONT_COLOR forState:UIControlStateNormal];
                [btn setTitle:[dc objectForKey:@"title"] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
                [btn addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:btn];
                col++;
                if (i%3<2) {
                    UIImageView* line=[[UIImageView alloc] initWithFrame:CGRectMake(40+w*col+5*col, y+5+4*row+40*row, 0.5, 36)];
                    [line setBackgroundColor:DEFAULT_LINE_COLOR];
                    [cell addSubview:line];
                }
                if (i%3==2) {
                    UIImageView* line=[[UIImageView alloc]initWithFrame:CGRectMake(50, 44*row+5, SCREEN_WIDTH-60, 0.5)];
                    [line setBackgroundColor:DEFAULT_LINE_COLOR];
                    [cell addSubview:line];
                }
            }
        }
    }
    cell.accessoryType=UITableViewCellAccessoryNone;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    return cell;
}



@end

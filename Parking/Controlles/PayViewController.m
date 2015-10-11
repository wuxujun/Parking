//
//  PayViewController.m
//  Parking
//
//  Created by xujunwu on 15/10/2.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import "PayViewController.h"
#import "UIViewController+NavigationBarButton.h"


@interface PayViewController ()

@end

@implementation PayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setCenterTitle:@"支付"];
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"历史" style:UIBarButtonItemStylePlain target:self action:@selector(onHistory:)];
    
}

-(IBAction)onHistory:(id)sender
{
    [self alertRequestResult:@"未查找出历史记录"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/




@end

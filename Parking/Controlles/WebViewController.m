//
//  WebViewController.m
//  Parking
//
//  Created by xujunwu on 15/9/23.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import "WebViewController.h"
#import "UIViewController+NavigationBarButton.h"
#import "UIView+LoadingView.h"


@interface WebViewController ()<UIWebViewDelegate>
{
    UIWebView       *mWebView;
    
}
@end

@implementation WebViewController
@synthesize infoDict=_infoDict;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (mWebView==nil) {
        mWebView=[[UIWebView alloc]initWithFrame:self.view.bounds];
        mWebView.delegate=self;
        mWebView.scalesPageToFit=NO;
        [self.view addSubview:mWebView];
    }
    if (self.infoDict) {
        if ([self.infoDict objectForKey:@"noticeTitle"]) {
            [self setCenterTitle:[self.infoDict objectForKey:@"noticeTitle"]];
        }
        if ([self.infoDict objectForKey:@"noticeLink"]) {
            
            [mWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[self.infoDict objectForKey:@"noticeLink"]]]];
        }
    }
    
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

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.view showHUDLoadingView:YES];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.view showHUDLoadingView:NO];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

@end

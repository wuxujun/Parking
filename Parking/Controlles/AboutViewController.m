//
//  AboutViewController.m
//  Parking
//
//  Created by xujunwu on 15/8/31.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "AboutViewController.h"
#import "UIView+LoadingView.h"
#import "UIViewController+NavigationBarButton.h"

@interface AboutViewController()<UIWebViewDelegate>
{
    UIWebView       *mWebView;
}

@end

@implementation AboutViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setCenterTitle:@"关于我们"];
    if (mWebView==nil) {
        mWebView=[[UIWebView alloc]initWithFrame:self.view.bounds];
        mWebView.delegate=self;
        mWebView.scalesPageToFit=NO;
        [self.view addSubview:mWebView];
    }
    NSString* requestUrl=[NSString stringWithFormat:@"%@",HTTP_ABOUT];
    [mWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

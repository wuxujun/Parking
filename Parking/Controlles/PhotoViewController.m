//
//  PhotoViewController.m
//  Parking
//
//  Created by xujunwu on 15/10/9.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import "PhotoViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AppConfig.h"

@interface PhotoViewController ()
{
    UIImageView*        imageView;
}
@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    imageView=[[UIImageView alloc]initWithFrame:self.view.bounds];
    [imageView setContentMode:UIViewContentModeScaleToFill];
    
    [self.view addSubview:imageView];
    
    if (self.infoDict) {
        if ([self.infoDict objectForKey:@"url"]) {
            
        }else{
            if ([[self.infoDict objectForKey:@"dataType"] isEqualToString:@"2"]) {
                [imageView setImage:[UIImage imageNamed:@"intruduce_0"]];
            }else if ([[self.infoDict objectForKey:@"dataType"] isEqualToString:@"3"]) {
                [imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@/%@",[[AppConfig getInstance] getPhotoFilePath],[self.infoDict objectForKey:@"image"]]]];
            }else{
                [imageView setImage:[UIImage imageNamed:@"parking"]];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.infoDict) {
        if ([self.infoDict objectForKey:@"url"]) {
                [imageView setImageWithURL:[NSURL URLWithString:[self.infoDict objectForKey:@"url"]] placeholderImage:[UIImage imageNamed:@"parking"]];
        }else{
            if ([[self.infoDict objectForKey:@"dataType"] isEqualToString:@"2"]) {
                [imageView setImage:[UIImage imageNamed:[self.infoDict objectForKey:@"image"]]];
            }else if ([[self.infoDict objectForKey:@"dataType"] isEqualToString:@"3"]) {
                [imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@/%@",[[AppConfig getInstance] getPhotoFilePath],[self.infoDict objectForKey:@"image"]]]];
            }
        }
    }
}

-(void)refresh
{
    if (self.infoDict) {
        if ([self.infoDict objectForKey:@"url"]) {
            [imageView setImageWithURL:[NSURL URLWithString:[self.infoDict objectForKey:@"url"]] placeholderImage:[UIImage imageNamed:@"parking"]];
        }else{
            if ([[self.infoDict objectForKey:@"dataType"] isEqualToString:@"2"]) {
                [imageView setImage:[UIImage imageNamed:[self.infoDict objectForKey:@"image"]]];
            }else if ([[self.infoDict objectForKey:@"dataType"] isEqualToString:@"3"]) {
               [imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@/%@",[[AppConfig getInstance] getPhotoFilePath],[self.infoDict objectForKey:@"image"]]]];
            }
        }
    }
}

@end

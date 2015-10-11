//
//  PointViewController.m
//  Parking
//
//  Created by xujunwu on 15/10/9.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import "PointViewController.h"
#import "UIViewController+NavigationBarButton.h"
#import "SPOIAnnotation.h"
#import <AMapSearchKit/AMapCommonObj.h>
#import "UserDefaultHelper.h"

@interface PointViewController ()

@end

@implementation PointViewController
@synthesize infoDict=_infoDict;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setCenterTitle:@"地图选点"];
     self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(onDone:)];
    
    
    [self configMapView];
}

-(IBAction)onDone:(id)sender
{
    [UserDefaultHelper setObject:[NSNumber numberWithFloat:self.mapView.centerCoordinate.latitude] forKey:CONF_MAP_SELECT_LAT];
    [UserDefaultHelper setObject:[NSNumber numberWithFloat:self.mapView.centerCoordinate.longitude] forKey:CONF_MAP_SELECT_LNG];
    NSDictionary* dict=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:self.mapView.centerCoordinate.longitude],@"latitude",[NSNumber numberWithFloat:self.mapView.centerCoordinate.longitude],@"longitude", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MAPSELECT_DONE object:dict];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)configMapView
{
    self.mapView.delegate = self;
    
    self.mapView.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view insertSubview:self.mapView atIndex:0];
    self.mapView.showsUserLocation = YES;
}

-(void)addPointView
{
    UIImageView* img=[[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-32.0)/2.0, (SCREEN_HEIGHT-32.0)/2, 32, 32)];
    [img setImage:[UIImage imageNamed:@"default_main_toolbaritem_around_normal"]];
    [self.view addSubview:img];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self addPointView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.infoDict) {
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake([[self.infoDict objectForKey:@"latitude"] floatValue],[[self.infoDict objectForKey:@"longitude"] floatValue] )];
        [self.mapView setZoomLevel:17.0 animated:YES];
    }
}

-(void)addPointToMapView
{
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    SPOIAnnotation  *poi=[[SPOIAnnotation alloc] initWithPOI:self.mapView.centerCoordinate.latitude lng:self.mapView.centerCoordinate.longitude];
    [self.mapView addAnnotation:poi];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(MAAnnotationView*)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation{
    if ([annotation isKindOfClass:[SPOIAnnotation class]]) {
        SPOIAnnotation* poi=(SPOIAnnotation*)annotation;
        NSString* uLocation=@"SPoi";
        MAPinAnnotationView *anView=(MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:uLocation];
        if (anView==nil) {
            anView=[[MAPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:uLocation];
        }
//        anView.draggable=YES;
//        anView.canShowCallout=YES;
//        anView.animatesDrop=YES;
        anView.centerOffset=CGPointMake(0, -18);
        return anView;
    }
    return [super mapView:mapView viewForAnnotation:annotation];
}

-(void)mapView:(MAMapView *)mapView didTouchPois:(NSArray *)pois
{
    HLog(@"%d",[pois count]);
    
}

- (void)mapView:(MAMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self addPointToMapView];
}


@end

//
//  LineMViewController.m
//  Parking
//
//  Created by xujunwu on 15/10/9.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import "LineMViewController.h"
#import "UIViewController+NavigationBarButton.h"
#import "NavPointAnnotation.h"

@interface LineMViewController ()
{
    NSMutableArray          *annotations;
}

@property(nonatomic,strong)MAPolyline   *polyline;
@property(nonatomic)BOOL    calRouteSuccess;

@end

@implementation LineMViewController

@synthesize lineType=_lineType;
@synthesize startPoint=_startPoint;
@synthesize endPoint=_endPoint;

- (void)viewDidLoad {
    [super viewDidLoad];
    annotations=[[NSMutableArray alloc]init];
    
    [self setCenterTitle:@"线路详情"];
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"default_common_list_icon_normal"] style:UIBarButtonItemStylePlain target:self action:@selector(showLine:)];
    
    
    // Do any additional setup after loading the view.
    [self configMapView];
    [self initAnnotations];

}

-(IBAction)showLine:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)configMapView
{
    self.mapView.delegate = self;
    
    self.mapView.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view insertSubview:self.mapView atIndex:0];
    self.mapView.showsUserLocation = YES;
}

-(void)initAnnotations
{
    NavPointAnnotation *beginPointA=[[NavPointAnnotation alloc]init];
    [beginPointA setCoordinate:CLLocationCoordinate2DMake([[self.startPoint objectForKey:@"latitude"] floatValue] , [[self.startPoint objectForKey:@"longitude"] floatValue] )];
    beginPointA.title=@"起点";
    beginPointA.navPointType=NavPointAnnotationStart;
    NavPointAnnotation *endPointA=[[NavPointAnnotation alloc]init];
    [endPointA setCoordinate:CLLocationCoordinate2DMake([[self.endPoint objectForKey:@"latitude"] floatValue] , [[self.endPoint objectForKey:@"longitude"] floatValue] )];
    endPointA.title=@"终点";
    endPointA.navPointType=NavPointAnnotationEnd;
    [annotations addObject:beginPointA];
    [annotations addObject:endPointA];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self searchLine];
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

-(void)searchLine
{
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    AMapNaviPoint* startP=[AMapNaviPoint locationWithLatitude:[[self.startPoint objectForKey:@"latitude"] floatValue] longitude:[[self.startPoint objectForKey:@"longitude"] floatValue]];
    
    AMapNaviPoint *endP=[AMapNaviPoint locationWithLatitude:[[self.endPoint objectForKey:@"latitude"] floatValue] longitude:[[self.endPoint objectForKey:@"longitude"] floatValue]];
    NSArray* startPoints=@[startP];
    NSArray* endPoints=@[endP];
    
    if (self.lineType==1) {
        [self.naviManager calculateDriveRouteWithStartPoints:startPoints endPoints:endPoints wayPoints:nil drivingStrategy:AMapNaviDrivingStrategyDefault];
    }else{
        [self.naviManager calculateWalkRouteWithStartPoints:startPoints endPoints:endPoints];
    }
    
}

-(void)naviManagerOnCalculateRouteSuccess:(AMapNaviManager *)naviManager
{
    [super naviManagerOnCalculateRouteSuccess:naviManager];
    [self showRouteWithNaviRoute:[[naviManager naviRoute] copy]];
    _calRouteSuccess=YES;
}

-(MAOverlayView*)mapView:(MAMapView *)mapView viewForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolyline class]]) {
        MAPolylineView* polylineView=[[MAPolylineView alloc]initWithPolyline:overlay];
        polylineView.lineWidth=5.0f;
        polylineView.strokeColor=[UIColor redColor];
//        polylineView.lineDash=YES;
        return polylineView;
    }
    return nil;
}

-(MAAnnotationView*)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[NavPointAnnotation class]]) {
        static NSString* idef=@"idef";
        MAPinAnnotationView* pointView=(MAPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:idef];
        if (pointView==nil) {
            pointView=[[MAPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:idef];
        }
        
        pointView.animatesDrop=NO;
        pointView.canShowCallout=NO;
        pointView.draggable=NO;
        NavPointAnnotation *navAnnotation=(NavPointAnnotation*)annotation;
        if (navAnnotation.navPointType==NavPointAnnotationStart) {
            [pointView setPinColor:MAPinAnnotationColorGreen];
        }else if(navAnnotation.navPointType==NavPointAnnotationEnd){
            [pointView setPinColor:MAPinAnnotationColorRed];
        }

        pointView.centerOffset=CGPointMake(0, -18);
        return pointView;
    }
    return nil;
}

-(void)showRouteWithNaviRoute:(AMapNaviRoute*)naviRoute
{
    if (naviRoute==nil) {
        return;
    }
    
    if (_polyline) {
        [self.mapView removeOverlay:_polyline];
        self.polyline=nil;
    }
    
    NSUInteger  coordianteCount=[naviRoute.routeCoordinates count];
    CLLocationCoordinate2D coordinates[coordianteCount];
    for (int i=0; i<coordianteCount; i++) {
        AMapNaviPoint* aCoordinate=[naviRoute.routeCoordinates objectAtIndex:i];
        coordinates[i]=CLLocationCoordinate2DMake(aCoordinate.latitude, aCoordinate.longitude);
    }
    _polyline=[MAPolyline polylineWithCoordinates:coordinates count:coordianteCount];
    [self.mapView addOverlay:_polyline];
  
    if (annotations.count>0) {
        [self.mapView addAnnotations:annotations];
        [self.mapView showAnnotations:annotations animated:YES];
    }
    
}

@end

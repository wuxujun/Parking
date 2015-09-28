//
//  SharedMapView.m
//  Parking
//
//  Created by xujunwu on 15/8/19.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "SharedMapView.h"

@interface SharedMapView ()
{
    NSMutableArray *_internalStatusArray;
}

@property (nonatomic, readwrite) MAMapView *mapView;

@end

@implementation SharedMapView

+ (instancetype)sharedInstance
{
    static SharedMapView *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SharedMapView alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Initialized

- (instancetype)init
{
    if (self = [super init])
    {
        [self initProperties];
        
        [self createMapView];
    }
    return self;
}

- (void)initProperties
{
    _internalStatusArray = [[NSMutableArray alloc] init];
}

- (void)createMapView
{
    if (self.mapView == nil)
    {
        self.mapView = [[MAMapView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
}

#pragma mark - Interface
- (void)stashMapViewStatus
{
    @synchronized (_internalStatusArray)
    {
        if (_internalStatusArray == nil)
        {
            return;
        }
        
        [_internalStatusArray addObject:[self.mapView getMapStatus]];
    }
}

- (void)popMapViewStatus
{
    @synchronized (_internalStatusArray)
    {
        if (_internalStatusArray == nil || ![_internalStatusArray count])
        {
            return;
        }
        
        [self.mapView setMapStatus:[_internalStatusArray lastObject] animated:NO];
        
        [_internalStatusArray removeLastObject];
    }
}
@end

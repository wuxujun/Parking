//
//  CustPOIAnnotation.m
//  Parking
//
//  Created by xujunwu on 15/9/1.
//  Copyright (c) 2015年 ___Hongkui___. All rights reserved.
//

#import "CustPOIAnnotation.h"

@interface CustPOIAnnotation()

@property (nonatomic,readwrite,strong)NSDictionary *dict;
@property (nonatomic,readwrite,assign)NSInteger index;
@property (nonatomic,readwrite,assign)BOOL      isSelected;

@end

@implementation CustPOIAnnotation
@synthesize dict=_dict;
@synthesize index=_index;
@synthesize isSelected=_isSelected;

-(NSString*)title
{
    return [self.dict objectForKey:@"title"];
}

-(NSString*)subtitle
{
    return [self.dict objectForKey:@"address"];
}

-(CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake([[self.dict objectForKey:@"latitude"] floatValue], [[self.dict objectForKey:@"longitude"] floatValue]);
}

-(id)initWithDictionary:(NSDictionary *)dict index:(NSInteger)idx isSelected:(BOOL)sel
{
    if (self==[super init]) {
        self.dict=dict;
        self.index=idx;
        self.isSelected=sel;
    }
    return self;
}


@end

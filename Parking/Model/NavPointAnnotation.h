//
//  NavPointAnnotation.h
//  Parking
//
//  Created by xujunwu on 15/10/9.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import <AMapNaviKit/AMapNaviKit.h>

typedef NS_ENUM(NSInteger,NavPointAnnotationType){
    NavPointAnnotationStart,
    NavPointAnnotationWay,
    NavPointAnnotationEnd
};

@interface NavPointAnnotation : MAPointAnnotation

@property(nonatomic,assign)NavPointAnnotationType   navPointType;
@end

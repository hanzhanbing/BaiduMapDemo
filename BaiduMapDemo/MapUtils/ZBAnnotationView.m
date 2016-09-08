//
//  ZBAnnotationView.m
//  BaiduMapDemo
//
//  Created by hanzhanbing on 16/8/31.
//  Copyright © 2016年 asj. All rights reserved.
//

#import "ZBAnnotationView.h"
#import "ZBPointAnnotation.h"

@implementation ZBAnnotationView

- (instancetype)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
    }
    return self;
}

+ (instancetype)annotationViewWithMap:(BMKMapView *)mapView withAnnotation:(id <BMKAnnotation>)annotation {
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        static NSString *identifier = @"AnnoID";
        // 1.从缓存池中取
        ZBAnnotationView *annoView = (ZBAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        // 2.如果缓存池中没有, 创建一个新的
        if (annoView == nil) {
            annoView = [[ZBAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        if ([annotation isKindOfClass:[ZBPointAnnotation class]]) {
            annoView.annotation = (ZBPointAnnotation *)annotation;
        }
        annoView.image = [UIImage imageNamed:@"Anno"];
        return annoView;
    }
    return nil;
}

@end

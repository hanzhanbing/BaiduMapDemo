//
//  ZBAnnotationView.h
//  BaiduMapDemo
//
//  Created by hanzhanbing on 16/8/31.
//  Copyright © 2016年 asj. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface ZBAnnotationView : BMKAnnotationView

/**
 *  创建方法
 *
 *  @param mapView 地图
 *
 *  @return 大头针
 */
+ (instancetype)annotationViewWithMap:(BMKMapView *)mapView withAnnotation:(id <BMKAnnotation>)annotation;

@end

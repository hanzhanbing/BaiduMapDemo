//
//  ZBPoiDetailVC.h
//  BaiduMapDemo
//
//  Created by hanzhanbing on 16/9/2.
//  Copyright © 2016年 asj. All rights reserved.
//

/**
 *  标注详情(可选择高德地图、百度地图、应用内3种路径规划方式)
 */

#import "BaseVC.h"
#import <BaiduMapAPI_Base/BMKUserLocation.h>
@class ZBPoi;

@interface ZBPoiDetailVC : BaseVC

/** poi*/
@property (nonatomic, strong) ZBPoi *poi;
/** 当前城市*/
@property (nonatomic, copy) NSString *city;
/** 用户当前位置*/
@property (nonatomic, strong) BMKUserLocation *userLocation;

@end

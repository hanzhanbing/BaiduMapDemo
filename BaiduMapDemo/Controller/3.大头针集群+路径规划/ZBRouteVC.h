//
//  ZBRouteVC.h
//  BaiduMapDemo
//
//  Created by hanzhanbing on 16/9/3.
//  Copyright © 2016年 asj. All rights reserved.
//

/**
 *  2点路径规划
 */

#import "BaseVC.h"
#import <BaiduMapAPI_Base/BMKUserLocation.h>
@class ZBPoi;

@interface ZBRouteVC : BaseVC

/** poi*/
@property (nonatomic, strong) ZBPoi *poi;

/** 用户当前位置*/
@property(nonatomic , strong) BMKUserLocation *userLocation;

/** 当前城市*/
@property (nonatomic, copy) NSString *city;

@end

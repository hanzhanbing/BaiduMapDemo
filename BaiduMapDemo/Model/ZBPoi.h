//
//  ZBPoi.h
//  BaiduMapDemo
//
//  Created by hanzhanbing on 16/9/2.
//  Copyright © 2016年 asj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZBPoi : NSObject

/** 地区名称*/
@property (nonatomic, copy) NSString *areaName;
/** 平均价格*/
@property (nonatomic, copy) NSString *avgPrice;
/** 评分*/
@property (nonatomic, copy) NSString *avgScore;
/** 标签*/
@property (nonatomic, copy) NSString *campaignTag;
/** 美食名称*/
@property (nonatomic, copy) NSString *cateName;
/** 频道*/
@property (nonatomic, copy) NSString *channel;
/** 展示图片*/
@property (nonatomic, copy) NSString *frontImg;
/** 纬度*/
@property (nonatomic, assign) double lat;
/** 经度*/
@property (nonatomic, assign) double lng;
/** 店名*/
@property (nonatomic, copy) NSString *name;

@end

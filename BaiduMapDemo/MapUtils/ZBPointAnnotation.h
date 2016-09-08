//
//  ZBPointAnnotation.h
//  BaiduMapDemo
//
//  Created by hanzhanbing on 16/9/2.
//  Copyright © 2016年 asj. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKPointAnnotation.h>

@class ZBPoi;

@interface ZBPointAnnotation : BMKPointAnnotation

/** poi*/
@property (nonatomic,retain) ZBPoi *poi;

/** 标注点的protocol，提供了标注类的基本信息函数*/
@property (nonatomic,weak) id<BMKAnnotation> delegate;

@end

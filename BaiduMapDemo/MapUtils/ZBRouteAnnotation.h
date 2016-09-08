//
//  ZBRouteAnnotation.h
//  BaiduMapDemo
//
//  Created by hanzhanbing on 16/9/4.
//  Copyright © 2016年 asj. All rights reserved.
//

/**
 *  路线的标注
 */

#import <BaiduMapAPI_Map/BMKPointAnnotation.h>

@interface ZBRouteAnnotation : BMKPointAnnotation

@property (nonatomic) int type; ///<0:起点 1：终点 2：公交 3：地铁 4:驾乘 5:途经点
@property (nonatomic) int degree;

@end

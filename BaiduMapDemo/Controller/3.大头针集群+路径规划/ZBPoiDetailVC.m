//
//  ZBPoiDetailVC.m
//  BaiduMapDemo
//
//  Created by hanzhanbing on 16/9/2.
//  Copyright © 2016年 asj. All rights reserved.
//

#import "ZBPoiDetailVC.h"
#import "ZBPoi.h"
#import "ZBRouteVC.h"
#import <MapKit/MapKit.h>

#define x_pi (3.14159265358979324 * 3000.0 / 180.0)

@interface ZBPoiDetailVC ()

@property (nonatomic,retain) UILabel *shopLocationLab;
@property (nonatomic,retain) UILabel *userLocationLab;
@property (nonatomic,retain) UILabel *customerLocationLab;
@property (nonatomic,retain) UIButton *pathPlanBtn;

@end

@implementation ZBPoiDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"店铺详情";
    
    [self initView]; //视图
}

#pragma mark - View

- (void)initView {
    //店铺信息
    _shopLocationLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, WIDTH-40, 100)];
    _shopLocationLab.numberOfLines = 10;
    _shopLocationLab.textAlignment = NSTextAlignmentCenter;
    _shopLocationLab.textColor = [UIColor blackColor];
    _shopLocationLab.text = [NSString stringWithFormat:@"店铺信息：{店名：%@ 所在城市：%@ 所在区域：%@ 经度：%f 维度：%f}",self.poi.name,self.city,self.poi.areaName,self.poi.lng,self.poi.lat];
    [self.view addSubview:_shopLocationLab];
    
    //配送员信息
    _userLocationLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 220, WIDTH-40, 100)];
    _userLocationLab.numberOfLines = 10;
    _userLocationLab.textAlignment = NSTextAlignmentCenter;
    _userLocationLab.textColor = [UIColor blackColor];
    _userLocationLab.text = [NSString stringWithFormat:@"配送员信息：{送餐员：%@ 所在城市：%@ 所在区域：%@ 经度：%f 维度：%f}",@"韩占禀",self.city,@"和义南站",self.userLocation.location.coordinate.longitude,self.userLocation.location.coordinate.latitude];
    [self.view addSubview:_userLocationLab];
    
    //客户信息
    _customerLocationLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 340, WIDTH-40, 100)];
    _customerLocationLab.numberOfLines = 10;
    _customerLocationLab.textAlignment = NSTextAlignmentCenter;
    _customerLocationLab.textColor = [UIColor blackColor];
    _customerLocationLab.text = [NSString stringWithFormat:@"客户信息：{接单人：%@ 所在城市：%@ 所在区域：%@ 经度：%f 维度：%f}",@"小李",self.city,@"劲松",116.459768,39.881832];
    [self.view addSubview:_customerLocationLab];
    
    _pathPlanBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, HEIGHT-70, WIDTH-60, 44)];
    _pathPlanBtn.showsTouchWhenHighlighted = YES;
    _pathPlanBtn.layer.cornerRadius = 5;
    _pathPlanBtn.layer.borderWidth = 1;
    _pathPlanBtn.layer.borderColor = AppThemeColor.CGColor;
    [_pathPlanBtn setTitle:@"路径规划" forState:UIControlStateNormal];
    [_pathPlanBtn setTitleColor:AppThemeColor forState:UIControlStateNormal];
    [_pathPlanBtn addTarget:self action:@selector(pathPlan) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_pathPlanBtn];
}

#pragma mark - methods 

- (void)pathPlan {
    NSLog(@"路径规划");
    
    // 初始化
    UIAlertController *alertDialog = [UIAlertController alertControllerWithTitle:@"路径规划" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    // 高德地图app导航
    UIAlertAction *mkRouteAction = [UIAlertAction actionWithTitle:@"高德地图app导航" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]){
            
            // 当前位置(起点)
            MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
            
            // 消除百度地图坐标和系统地图坐标之间的误差
            double x = self.poi.lng - 0.0065, y = self.poi.lat - 0.006;
            double z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi);
            double theta = atan2(y, x) - 0.000003 * cos(x * x_pi);
            double gg_lon = z * cos(theta);
            double gg_lat = z * sin(theta);
            CLLocationCoordinate2D endCoord = CLLocationCoordinate2DMake(gg_lat, gg_lon);
            
            // 目的地(终点)
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:endCoord addressDictionary:nil]];
            
            NSArray *items = [NSArray arrayWithObjects:currentLocation, toLocation, nil];
            
            NSDictionary *options = @{ MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsMapTypeKey: [NSNumber numberWithInteger:MKMapTypeStandard], MKLaunchOptionsShowsTrafficKey:@YES }; //打开苹果自身地图应用，并呈现特定的item
            
            [MKMapItem openMapsWithItems:items launchOptions:options];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的手机没有安装高德地图" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
        }
    }];
    
    // 百度地图app导航
    UIAlertAction *bmkRouteAction = [UIAlertAction actionWithTitle:@"百度地图app导航" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://map/"]]){
            NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin=latlng:%f,%f|name:我的位置&destination=latlng:%f,%f|name:终点&mode=driving",self.userLocation.location.coordinate.latitude, self.userLocation.location.coordinate.longitude,self.poi.lat, self.poi.lng] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlString]];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的手机没有安装百度地图" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
        }
    }];
    
    // 应用内导航
    UIAlertAction *appRouteAction = [UIAlertAction actionWithTitle:@"应用内导航" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ZBRouteVC *routeVC = [[ZBRouteVC alloc] init];
        routeVC.poi = self.poi;
        routeVC.city = self.city;
        routeVC.userLocation = self.userLocation;
        [self.navigationController pushViewController:routeVC animated:NO];
    }];
    
    // 取消
    UIAlertAction *cancelRouteAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    // 添加操作（顺序就是呈现的上下顺序）
    [alertDialog addAction:mkRouteAction];
    [alertDialog addAction:bmkRouteAction];
    [alertDialog addAction:appRouteAction];
    [alertDialog addAction:cancelRouteAction];
    
    // 呈现视图
    [self presentViewController:alertDialog animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

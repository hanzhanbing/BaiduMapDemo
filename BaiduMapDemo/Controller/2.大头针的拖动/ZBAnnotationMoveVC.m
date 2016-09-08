//
//  ZBAnnotationMoveVC.m
//  BaiduMapDemo
//
//  Created by hanzhanbing on 16/9/1.
//  Copyright © 2016年 asj. All rights reserved.
//

#import "ZBAnnotationMoveVC.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>

@interface ZBAnnotationMoveVC ()<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate>

@property (nonatomic,retain) BMKMapView *mapView;
@property (nonatomic,retain) BMKLocationService *locService;
@property (nonatomic,retain) BMKUserLocation *userLocation;
@property (nonatomic,retain) BMKGeoCodeSearch *geoSearch;
@property (nonatomic,retain) BMKPointAnnotation *pointAnnotation;

@end

@implementation ZBAnnotationMoveVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.upSwipe.enabled = NO; //屏蔽右滑返回手势
    
    [self.view addSubview:self.mapView];
    
    self.userLocation = [[BMKUserLocation alloc] init];
    self.geoSearch = [[BMKGeoCodeSearch alloc] init];
    
    [self initLocService]; //定位
}

#pragma mark - Getters

- (BMKMapView *)mapView {
    if (!_mapView) {
        _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
        [_mapView setZoomLevel:18]; //3-21级
        _mapView.showMapScaleBar = YES; //显示比例尺
        _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
        _mapView.showsUserLocation = NO; //不显示定位图层
    }
    
    return _mapView;
}

#pragma mark - 定位(后台持续定位)

- (void)initLocService {
    
    _locService = [[BMKLocationService alloc] init];
    _locService.delegate = self;
    _locService.distanceFilter = 20;
    _locService.desiredAccuracy = kCLLocationAccuracyBest;
    
    //这是iOS9中针对后台定位推出的新属性，不设置的话可能会出现顶部蓝条的哦(类似热点连接)
    if (SystemVersion >=9 ) {
        _locService.allowsBackgroundLocationUpdates = YES;
    }
    
    //设置是否允许系统自动暂停定位，这里要设置为NO，如果没有设置默认为YES，后台定位持续20分钟左右就停止了！
    _locService.pausesLocationUpdatesAutomatically = NO;
    
    [_locService startUserLocationService];
}

#pragma mark - BMKLocationServiceDelegate

//用户位置更新后，会调用此函数
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    
    [_mapView updateLocationData:userLocation]; //动态更新我的位置数据
    [_mapView setCenterCoordinate:userLocation.location.coordinate animated:YES]; //当前地图的中心点
    self.userLocation = userLocation; //用户当前位置
    
    //发起反向地理编码检索
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude};
    BMKReverseGeoCodeOption *searchOption = [[BMKReverseGeoCodeOption alloc] init];
    searchOption.reverseGeoPoint = pt;
    [_geoSearch reverseGeoCode:searchOption];
}

#pragma mark - 接收反向地理编码结果

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    if (error == BMK_SEARCH_NO_ERROR) {
        NSLog(@"标注当前位置：{地址：%@ 经度：%f 维度：%f}",result.address,result.location.longitude,result.location.latitude);
        
        //添加标注
        if (!_pointAnnotation) {
            _pointAnnotation = [[BMKPointAnnotation alloc] init];
            [self.mapView addAnnotation:_pointAnnotation];
        }
        _pointAnnotation.title = result.address;
        _pointAnnotation.coordinate = result.location;
        [self.mapView selectAnnotation:_pointAnnotation animated:YES]; //弹出气泡
    }
}

#pragma mark - BMKMapViewDelegate

//创建标注视图
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation {
    //创建大头针
    static NSString *ID = @"RenameMarkID";
    BMKPinAnnotationView *annoView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:ID];
    if (!annoView) {
        annoView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ID];
    }
    
    //设置颜色
    annoView.pinColor = BMKPinAnnotationColorGreen;
    //从天上掉下效果
    annoView.animatesDrop = NO;
    //设置可拖拽
    annoView.draggable = YES;
    
    return annoView;
}

//标注气泡弹出
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view {
    //当标注气泡弹出之后，设置开始拖动状态
    view.dragState = BMKAnnotationViewDragStateStarting;
}

//地图区域即将改变时会调用此接口
- (void)mapView:(BMKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    NSLog(@"拖拽开始");
    
    [self.mapView deselectAnnotation:_pointAnnotation animated:YES]; //隐藏气泡
}

//地图区域改变完成后会调用此接口
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    NSLog(@"拖拽结束");
    
    //将View坐标转换成地图经纬度坐标
    CLLocationCoordinate2D pt = [_mapView convertPoint:self.mapView.center toCoordinateFromView:self.mapView];
    
    //发起反向地理编码检索
    BMKReverseGeoCodeOption *searchOption = [[BMKReverseGeoCodeOption alloc] init];
    searchOption.reverseGeoPoint = pt;
    [_geoSearch reverseGeoCode:searchOption];
}

- (void)viewWillAppear:(BOOL)animated {
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    _geoSearch.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
    _geoSearch.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

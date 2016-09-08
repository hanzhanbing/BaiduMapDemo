//
//  ZBAnnotationsVC.m
//  BaiduMapDemo
//
//  Created by hanzhanbing on 16/9/2.
//  Copyright © 2016年 asj. All rights reserved.
//

#import "ZBAnnotationsVC.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>
#import "ZBAnnotationView.h"
#import "ZBPointAnnotation.h"
#import <AFNetworking.h>
#import <MJExtension.h>
#import "ZBPoi.h"
#import "ZBPaopaoView.h"
#import "ZBPoiDetailVC.h"

@interface ZBAnnotationsVC ()<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,ZBPaopaoViewDelagate>

@property (nonatomic,retain) BMKMapView *mapView;
@property (nonatomic,retain) BMKLocationService *locService;
@property (nonatomic,retain) BMKGeoCodeSearch *geoSearch;
/** 用户当前位置*/
@property (nonatomic,retain) BMKUserLocation *userLocation;
/** 当前城市*/
@property (nonatomic, copy) NSString *city;

@end

@implementation ZBAnnotationsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.upSwipe.enabled = NO; //屏蔽右滑返回手势
    
    [self.view addSubview:self.mapView];
    
    self.userLocation = [[BMKUserLocation alloc] init];
    self.geoSearch = [[BMKGeoCodeSearch alloc] init];
    
    [self initLocService]; //定位
    
    [self getData]; //加载美团数据
}

#pragma mark - Data 

- (void)getData {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *urlString = @"http://api.meituan.com/meishi/filter/v4/deal/select/city/1/area/14/cate/1?__skua=58c45e3fe9ccacce6400c5a736b76480&userid=267752722&__vhost=api.meishi.meituan.com&movieBundleVersion=100&wifi-mac=8c%3Af2%3A28%3Afc%3A41%3A92&utm_term=6.5.1&limit=25&ci=1&__skcy=jyDTYwzfsbzflQbUtxRRR1RK2Ag%3D&__skts=1466298960.130064&sort=defaults&__skno=5210AD02-055C-47B7-BD23-A26EB36E2A20&wifi-name=MERCURY_4192&uuid=E158E8C43627D4B0B2BA94FC17DD78F08B7148D4A037A9933F3180FC1E550587&utm_content=E158E8C43627D4B0B2BA94FC17DD78F08B7148D4A037A9933F3180FC1E550587&utm_source=AppStore&version_name=6.5.1&mypos=38.300178%2C116.909954&utm_medium=iphone&wifi-strength=&wifi-cur=0&offset=0&poiFields=cityId%2Clng%2CfrontImg%2CavgPrice%2CavgScore%2Cname%2Clat%2CcateName%2CareaName%2CcampaignTag%2Cabstracts%2Crecommendation%2CpayInfo%2CpayAbstracts%2CqueueStatus&hasGroup=true&utm_campaign=AgroupBgroupD200Ghomepage_category1_1__a1&__skck=3c0cf64e4b039997339ed8fec4cddf05&msid=AE66B26D-47FB-4959-B3F3-FE25606FF0CB2016-06-19-09-1327";
    
    [[AFHTTPSessionManager manager] GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSArray *data = responseObject[@"data"];
        for (NSDictionary *dict in data) {
            NSDictionary *poiDict = dict[@"poi"];
            NSLog(@"poi信息：%@",poiDict);
            ZBPoi *poi = [ZBPoi mj_objectWithKeyValues:poiDict];
            ZBPointAnnotation *annotation = [[ZBPointAnnotation alloc] init];
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(poi.lat, poi.lng);
            annotation.coordinate = coordinate;
            annotation.poi = poi;
            [_mapView addAnnotation:annotation];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

#pragma mark - Getters

- (BMKMapView *)mapView {
    if (!_mapView) {
        _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
        [_mapView setZoomLevel:12]; //3-21级
        _mapView.showMapScaleBar = YES; //显示比例尺
        _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
        _mapView.showsUserLocation = YES; //显示定位图层
        
        //定位图层自定义样式
        BMKLocationViewDisplayParam *userlocationStyle = [[BMKLocationViewDisplayParam alloc] init];
        userlocationStyle.isRotateAngleValid = YES;
        userlocationStyle.isAccuracyCircleShow = NO; //不显示精度圈
        [_mapView updateLocationViewWithParam:userlocationStyle];
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
        self.city = result.addressDetail.city;
        NSLog(@"用户当前位置：{地址：%@ 经度：%f 维度：%f}",result.address,result.location.longitude,result.location.latitude);
    }
}

#pragma mark -BMKMapViewDelegate

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation {
    // 创建大头针
    ZBAnnotationView *annotationView = [ZBAnnotationView annotationViewWithMap:mapView withAnnotation:annotation];
    annotationView.draggable = NO; //不可拖动
    
    // 绑定大头针上的View视图
    ZBPaopaoView *paopaoView = [[ZBPaopaoView alloc] initWithFrame:CGRectMake(0, 0, 180, 60)];
    paopaoView.delegate = self;
    ZBPointAnnotation *anno = (ZBPointAnnotation *)annotationView.annotation;
    paopaoView.poi = anno.poi;
    annotationView.paopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:paopaoView];
    
    return annotationView;
}

#pragma mark - ZBPaopaoViewDelagate

- (void)paopaoView:(ZBPaopaoView *)paopapView coverButtonClickWithPoi:(ZBPoi *)poi {
    NSLog(@"点击泡泡");
    ZBPoiDetailVC *detailVC = [[ZBPoiDetailVC alloc] init];
    detailVC.city = self.city;
    detailVC.poi = poi;
    detailVC.userLocation = self.userLocation;
    [self.navigationController pushViewController:detailVC animated:NO];
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

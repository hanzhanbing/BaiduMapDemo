//
//  ZBThreePointRouteVC.m
//  BaiduMapDemo
//
//  Created by hanzhanbing on 16/9/4.
//  Copyright © 2016年 asj. All rights reserved.
//

#import "ZBThreePointRouteVC.h"
#import "UIImage+Rotate.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKGeometry.h>
#import "ZBPoi.h"
#import "ZBPointAnnotation.h"
#import "ZBRouteAnnotation.h"

#define MYBUNDLE_NAME @ "mapapi.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]

@interface ZBThreePointRouteVC ()<BMKMapViewDelegate,BMKRouteSearchDelegate>

@property (nonatomic,retain) BMKMapView *mapView;
@property (nonatomic,retain) BMKRouteSearch *routeSearch;

@end

@implementation ZBThreePointRouteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.upSwipe.enabled = NO; //屏蔽右滑返回手势
    
    [self.view addSubview:self.mapView];
    
    self.routeSearch = [[BMKRouteSearch alloc] init];
    
    //驾车路线
    [self showDriveSearch];
}

#pragma mark - Getters

- (BMKMapView *)mapView {
    if (!_mapView) {
        _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
        [_mapView setZoomLevel:18]; //3-21级
        _mapView.showMapScaleBar = YES; //显示比例尺
        _mapView.buildingsEnabled = YES;
        _mapView.overlookEnabled = YES;
        _mapView.overlooking = -45;
    }
    
    return _mapView;
}

#pragma mark - 显示大头针
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation {
    if (![annotation isKindOfClass:[ZBRouteAnnotation class]]) return nil;
    return [self getRouteAnnotationView:mapView viewForAnnotation:(ZBRouteAnnotation *)annotation];
}

#pragma mark 获取路线的标注，显示到地图
- (BMKAnnotationView*)getRouteAnnotationView:(BMKMapView *)mapview viewForAnnotation:(ZBRouteAnnotation*)routeAnnotation {
    
    BMKAnnotationView *view = nil;
    switch (routeAnnotation.type) {
        case 0:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"start_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc] initWithAnnotation:routeAnnotation reuseIdentifier:@"start_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMapBundlePath:@"images/icon_nav_start"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = true;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 1:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"end_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc] initWithAnnotation:routeAnnotation reuseIdentifier:@"end_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMapBundlePath:@"images/icon_nav_end"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = true;
            }
            view.annotation =routeAnnotation;
        }
            break;
        case 4:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"route_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc] initWithAnnotation:routeAnnotation reuseIdentifier:@"route_node"];
                view.canShowCallout = true;
            } else {
                [view setNeedsDisplay];
            }
            UIImage *image = [UIImage imageWithContentsOfFile:[self getMapBundlePath:@"images/icon_direction"]];
            view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
            view.annotation = routeAnnotation;
        }
            break;
        case 5:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"center_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc] initWithAnnotation:routeAnnotation reuseIdentifier:@"center_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMapBundlePath:@"images/icon_nav_waypoint"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = true;
            }
            view.annotation =routeAnnotation;
        }
            break;
        default:
            break;
    }
    return view;
}

#pragma mark 驾车路线
-(void)showDriveSearch {
    //线路检索节点信息
    
    // 起点
    BMKPlanNode *start = [[BMKPlanNode alloc] init];
    CLLocationCoordinate2D startCoordinate = CLLocationCoordinate2DMake(39.8195330000,116.4021840000);
    start.pt = startCoordinate;
    start.cityName = @"北京";
    
    // 途经点
    BMKPlanNode *wayPoint = [[BMKPlanNode alloc] init];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(39.8588730000,116.4075120000);
    wayPoint.pt = centerCoordinate;
    wayPoint.cityName = @"北京";
    wayPoint.name = @"南园路果园";
    NSMutableArray *wayPointsArray = [NSMutableArray array];
    [wayPointsArray addObject:wayPoint];
    
    // 终点
    BMKPlanNode *end = [[BMKPlanNode alloc] init];
    CLLocationCoordinate2D endCoordinate = CLLocationCoordinate2DMake(39.8996680000,116.5164410000);
    end.pt = endCoordinate;
    end.cityName = @"北京";
    
    // 路线
    BMKDrivingRoutePlanOption *drivingRouteSearchOption = [[BMKDrivingRoutePlanOption alloc] init];
    drivingRouteSearchOption.from = start;
    drivingRouteSearchOption.to = end;
    drivingRouteSearchOption.wayPointsArray = wayPointsArray; // <=10
    [_routeSearch drivingSearch:drivingRouteSearchOption];
}

#pragma mark 返回驾乘搜索结果
- (void)onGetDrivingRouteResult:(BMKRouteSearch*)searcher result:(BMKDrivingRouteResult*)result errorCode:(BMKSearchErrorCode)error {
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    if (error == BMK_SEARCH_NO_ERROR) {
        //表示一条驾车路线
        BMKDrivingRouteLine* plan = (BMKDrivingRouteLine*)[result.routes objectAtIndex:0];
        // 计算路线方案中的路段数目
        int size = (int)[plan.steps count];
        int planPointCounts = 0;
        for (int i = 0; i < size; i++) {
            //表示驾车路线中的一个路段
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:i];
            if(i==0){
                ZBRouteAnnotation* item = [[ZBRouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点";
                item.type = 0;
                [_mapView addAnnotation:item]; // 添加起点标注
                
            }else if(i==size-1){
                ZBRouteAnnotation* item = [[ZBRouteAnnotation alloc]init];
                item.coordinate = plan.terminal.location;
                item.title = @"终点";
                item.type = 1;
                [_mapView addAnnotation:item]; // 添加终点标注
            }
       
            //添加annotation节点
            ZBRouteAnnotation* item = [[ZBRouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.entraceInstruction;
            item.degree = transitStep.direction * 30;
            item.type = 4;
            [_mapView addAnnotation:item];
            
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        // 添加途经点
        if (plan.wayPoints) {
            for (BMKPlanNode* tempNode in plan.wayPoints) {
                ZBRouteAnnotation* item = [[ZBRouteAnnotation alloc]init];
                item.coordinate = tempNode.pt;
                item.type = 5;
                item.title = tempNode.name;
                [_mapView addAnnotation:item];
            }
        }
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
        }
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:polyLine]; // 添加路线overlay
        delete []temppoints;
        [self mapViewFitPolyLine:polyLine];
    }
}

#pragma mark 根据overlay生成对应的View
-(BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay {
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:1];
        polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        polylineView.lineWidth = 3.0;
        return polylineView;
    }
    return nil;
}

#pragma mark  根据polyline设置地图范围
- (void)mapViewFitPolyLine:(BMKPolyline *) polyLine {
    CGFloat ltX, ltY, rbX, rbY;
    
    if (polyLine.pointCount < 1) return;
    BMKMapPoint pt = polyLine.points[0];
    ltX = pt.x, ltY = pt.y;
    rbX = pt.x, rbY = pt.y;
    
    for (int i = 0; i < polyLine.pointCount; i++) {
        BMKMapPoint pt = polyLine.points[i];
        if (pt.x < ltX) {
            ltX = pt.x;
        }
        if (pt.x > rbX) {
            rbX = pt.x;
        }
        if (pt.y > ltY) {
            ltY = pt.y;
        }
        if (pt.y < rbY) {
            rbY = pt.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX , ltY);
    rect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY);
    [_mapView setVisibleMapRect:rect];
    _mapView.zoomLevel = _mapView.zoomLevel - 0.3;
}

#pragma mark - Utils

//获取百度地图SDK资源路径
- (NSString*)getMapBundlePath:(NSString *)filename {
    
    NSBundle *libBundle = MYBUNDLE ;
    if ( libBundle && filename ) {
        NSString *s=[[libBundle resourcePath ] stringByAppendingPathComponent:filename];
        return s;
    }
    return nil ;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _routeSearch.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _routeSearch.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

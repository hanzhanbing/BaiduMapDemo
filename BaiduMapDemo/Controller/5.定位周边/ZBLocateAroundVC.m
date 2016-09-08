//
//  ZBLocateAroundVC.m
//  BaiduMapDemo
//
//  Created by hanzhanbing on 16/9/5.
//  Copyright © 2016年 asj. All rights reserved.
//

#import "ZBLocateAroundVC.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>
#import <BaiduMapAPI_Search/BMKPoiSearchType.h>

#define kBaiduMapMaxHeight 300
#define kCurrentLocationBtnWH 50
#define kPading 10

@interface ZBLocateAroundVC ()<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)BMKMapView* mapView;
@property(nonatomic,strong)BMKLocationService* locService;
@property(nonatomic,strong)BMKGeoCodeSearch* geocodesearch;

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *dataSource;

@property(nonatomic,assign)CLLocationCoordinate2D currentCoordinate;
@property(nonatomic,assign)NSInteger currentSelectLocationIndex;
@property(nonatomic,strong)UIImageView *centerCallOutImageView;
@property(nonatomic,strong)UIButton *currentLocationBtn;

@end

@implementation ZBLocateAroundVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.upSwipe.enabled = NO; //屏蔽右滑返回手势
    
    [self configUI];
    
    [self startLocation];
    
}

-(void)configUI
{
    //BMKMapView
    self.mapView.frame = CGRectMake(0, 0, WIDTH, kBaiduMapMaxHeight);
    [self.view addSubview:self.mapView];
    
    //固定定位图标
    self.centerCallOutImageView.frame = CGRectMake(0, 0, 30, 30);
    self.centerCallOutImageView.center = self.mapView.center;
    [self.view addSubview:self.centerCallOutImageView];
    [self.view bringSubviewToFront:self.centerCallOutImageView];
    
    [self.mapView layoutIfNeeded];
    
    //UITableView
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.mapView.frame), WIDTH, HEIGHT-kBaiduMapMaxHeight);
    [self.view addSubview:self.tableView];
    
    //定位按钮
    self.currentLocationBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    [self.currentLocationBtn setImage:[UIImage imageNamed:@"Location_black_icon"] forState:UIControlStateNormal];
    [self.currentLocationBtn setImage:[UIImage imageNamed:@"Location_blue_icon"] forState:UIControlStateSelected];
    [self.currentLocationBtn addTarget:self action:@selector(startLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.currentLocationBtn];
    [self.view bringSubviewToFront:self.currentLocationBtn];
    self.currentLocationBtn.frame = CGRectMake(10, CGRectGetMaxY(self.mapView.frame)-kCurrentLocationBtnWH-10, kCurrentLocationBtnWH, kCurrentLocationBtnWH);
}

#pragma mark - methods

//开始定位
-(void)startLocation
{
    self.currentSelectLocationIndex=0;
    self.currentLocationBtn.selected=YES;
    [self.locService startUserLocationService];
    self.mapView.showsUserLocation = NO;//先关闭显示的定位图层
    self.mapView.userTrackingMode = BMKUserTrackingModeFollow;//设置定位的状态
    self.mapView.showsUserLocation = YES;//显示定位图层
}

-(void)startGeocodesearchWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    //反地理编码
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = coordinate;
    [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
}

-(void)setCurrentCoordinate:(CLLocationCoordinate2D)currentCoordinate
{
    _currentCoordinate=currentCoordinate;
    [self startGeocodesearchWithCoordinate:currentCoordinate];
}

#pragma mark - BMKMapViewDelegate

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [self.mapView updateLocationData:userLocation];
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    self.currentLocationBtn.selected=NO;
    [self.mapView updateLocationData:userLocation];
    self.currentCoordinate=userLocation.location.coordinate;
    
    if (self.currentCoordinate.latitude!=0)
    {
        [self.locService stopUserLocationService];
    }
}

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    CLLocationCoordinate2D tt =[mapView convertPoint:self.centerCallOutImageView.center toCoordinateFromView:self.centerCallOutImageView];
    self.currentCoordinate=tt;
}

#pragma mark - BMKGeoCodeSearchDelegate

/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR)
    {
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:result.poiList];
        
        //把当前定位信息自定义组装 放进数组首位
        BMKPoiInfo *first =[[BMKPoiInfo alloc]init];
        first.address=result.address;
        first.name=@"[当前位置]";
        first.pt=result.location;
        first.city=result.addressDetail.city;
        [self.dataSource insertObject:first atIndex:0];
        
        [self.tableView reloadData];
    }
}

#pragma mark - TableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"LocationCell";
    
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"LocationCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    BMKPoiInfo *model=[self.dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text=model.name;
    cell.detailTextLabel.text=model.address;
    cell.detailTextLabel.textColor=[UIColor grayColor];
    
    if (self.currentSelectLocationIndex==indexPath.row)
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType=UITableViewCellAccessoryNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BMKPoiInfo *model=[self.dataSource objectAtIndex:indexPath.row];
    NSLog(@"选择地址信息：{地址：%@ 经度：%f 维度：%f}",[NSString stringWithFormat:@"%@%@",model.address,model.name],model.pt.longitude,model.pt.latitude);
    //BMKMapStatus *mapStatus =[self.mapView getMapStatus];
    //mapStatus.targetGeoPt=model.pt;
    //[self.mapView setMapStatus:mapStatus withAnimation:YES];
    self.currentSelectLocationIndex=indexPath.row;
    [self.tableView reloadData];
}

#pragma mark - Getters

-(BMKMapView*)mapView
{
    if (_mapView==nil)
    {
        _mapView =[BMKMapView new];
        _mapView.zoomEnabled=NO;
        _mapView.zoomEnabledWithTap=NO;
        _mapView.zoomLevel=17;
    }
    return _mapView;
}

-(BMKLocationService*)locService
{
    if (_locService==nil)
    {
        _locService = [[BMKLocationService alloc]init];
    }
    return _locService;
}

-(BMKGeoCodeSearch*)geocodesearch
{
    if (_geocodesearch==nil)
    {
        _geocodesearch=[[BMKGeoCodeSearch alloc]init];
    }
    return _geocodesearch;
}

-(UITableView*)tableView
{
    if (_tableView==nil)
    {
        _tableView=[UITableView new];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        
    }
    return _tableView;
}

-(UIImageView*)centerCallOutImageView
{
    if (_centerCallOutImageView==nil)
    {
        _centerCallOutImageView=[UIImageView new];
        [_centerCallOutImageView setImage:[UIImage imageNamed:@"Location_green_icon"]];
    }
    return _centerCallOutImageView;
}

-(NSMutableArray*)dataSource
{
    if (_dataSource==nil) {
        _dataSource=[[NSMutableArray alloc]init];
    }
    
    return _dataSource;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.mapView viewWillAppear];
    self.mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    self.locService.delegate = self;
    self.geocodesearch.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.mapView viewWillDisappear];
    self.mapView.delegate = nil; // 不用时，置nil
    self.locService.delegate = nil;
    self.geocodesearch.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

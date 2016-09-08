//
//  ZBHomeVC.m
//  BaiduMapDemo
//
//  Created by hanzhanbing on 16/9/1.
//  Copyright © 2016年 asj. All rights reserved.
//

#import "ZBHomeVC.h"
#import "ZBMapBaseVC.h"
#import "ZBAnnotationMoveVC.h"
#import "ZBAnnotationsVC.h"
#import "ZBThreePointRouteVC.h"
#import "ZBLocateAroundVC.h"

@interface ZBHomeVC ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation ZBHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"百度地图";
    
}

#pragma mark - UITableViewDelegate、UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"1.百度地图基础功能";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"2.大头针的拖动";
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"3.大头针集群+路径规划";
    } else if (indexPath.row == 3) {
        cell.textLabel.text = @"4.“我取送”3点路径规划";
    } else if (indexPath.row == 4) {
        cell.textLabel.text = @"5.定位周边";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        ZBMapBaseVC *mapBaseVC = [[ZBMapBaseVC alloc] init];
        mapBaseVC.title = @"1.百度地图基础功能";
        [self.navigationController pushViewController:mapBaseVC animated:NO];
    } else if (indexPath.row == 1) {
        ZBAnnotationMoveVC *annoMoveVC = [[ZBAnnotationMoveVC alloc] init];
        annoMoveVC.title = @"2.大头针的拖动";
        [self.navigationController pushViewController:annoMoveVC animated:NO];
    } else if (indexPath.row == 2) {
        ZBAnnotationsVC *annosVC = [[ZBAnnotationsVC alloc] init];
        annosVC.title = @"3.大头针集群+路径规划";
        [self.navigationController pushViewController:annosVC animated:NO];
    } else if (indexPath.row == 3) {
        ZBThreePointRouteVC *routeVC = [[ZBThreePointRouteVC alloc] init];
        routeVC.title = @"4.“我取送”3点路径规划";
        [self.navigationController pushViewController:routeVC animated:NO];
    } else if (indexPath.row == 4) {
        ZBLocateAroundVC *locateAroundVC = [[ZBLocateAroundVC alloc] init];
        locateAroundVC.title = @"5.定位周边";
        [self.navigationController pushViewController:locateAroundVC animated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

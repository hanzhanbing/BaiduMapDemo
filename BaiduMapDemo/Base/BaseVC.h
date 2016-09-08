//
//  BaseVC.h
//  BaiduMapDemo
//
//  Created by hanzhanbing on 16/8/30.
//  Copyright © 2016年 asj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseVC : UIViewController<UIGestureRecognizerDelegate>

/** self.upSwipe.enabled = NO; //屏蔽右滑返回手势 */
@property (nonatomic, strong) UISwipeGestureRecognizer *upSwipe;

/** self.isHideNav = YES; //没有导航条 */
@property (nonatomic, assign) BOOL isHideNav;

@end

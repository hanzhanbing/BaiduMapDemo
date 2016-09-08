//
//  ZBPaopaoView.h
//  BaiduMapDemo
//
//  Created by hanzhanbing on 16/9/2.
//  Copyright © 2016年 asj. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZBPoi, ZBPaopaoView;

@protocol ZBPaopaoViewDelagate <NSObject>

-(void)paopaoView:(ZBPaopaoView *)paopapView coverButtonClickWithPoi:(ZBPoi *)poi;

@end

@interface ZBPaopaoView : UIView

/** poi*/
@property (nonatomic, strong) ZBPoi *poi;

/** ZBPaopaoViewDelagate*/
@property (nonatomic, weak) id<ZBPaopaoViewDelagate> delegate;

@end

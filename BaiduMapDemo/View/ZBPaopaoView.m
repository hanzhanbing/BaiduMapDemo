//
//  ZBPaopaoView.m
//  BaiduMapDemo
//
//  Created by hanzhanbing on 16/9/2.
//  Copyright © 2016年 asj. All rights reserved.
//

#import "ZBPaopaoView.h"
#import "ZBPoi.h"
#import <UIImageView+WebCache.h>

@interface ZBPaopaoView ()

@property (nonatomic,retain) UIButton *bgButton;
@property (nonatomic,retain) UIImageView *shopImage;
@property (nonatomic,retain) UILabel *nameLab;
@property (nonatomic,retain) UILabel *areaLab;

@end

@implementation ZBPaopaoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5;
        
        _bgButton = [[UIButton alloc] initWithFrame:self.frame];
        [_bgButton addTarget:self action:@selector(clickPaoView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_bgButton];
        
        _shopImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        [self addSubview:_shopImage];
        
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(60, 5, 120, 20)];
        _nameLab.font = [UIFont systemFontOfSize:13];
        [self addSubview:_nameLab];
        
        _areaLab = [[UILabel alloc] initWithFrame:CGRectMake(60, 30, 120, 26)];
        _areaLab.font = [UIFont systemFontOfSize:13];
        [self addSubview:_areaLab];
        
    }
    return self;
}

- (void)setPoi:(ZBPoi *)poi {
    _poi = poi;
    
    [self.shopImage sd_setImageWithURL:[NSURL URLWithString:poi.frontImg]];
    [self.shopImage sd_setImageWithURL:[NSURL URLWithString:poi.frontImg] placeholderImage:[UIImage imageNamed:@"ShopHeadImage"]];
    self.nameLab.text = poi.name;
    self.areaLab.text = poi.areaName;
}

- (void)clickPaoView {
    if ([self.delegate respondsToSelector:@selector(paopaoView:coverButtonClickWithPoi:)]) {
        [self.delegate paopaoView:self coverButtonClickWithPoi:self.poi];
    }
}

@end

//
//  CFDanmakuInfo.h
//  DanmuDemo
//
//  Created by wangcheng on 15/8/6.
//  Copyright (c) 2015年 wangcheng. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CFDanmaku;

@interface CFDanmakuInfo : NSObject

// 弹幕内容label
@property(nonatomic, weak) UILabel  *playLabel;
// 弹幕label frame
//@property(nonatomic, assign) CGRect labelFrame;
//
@property(nonatomic, assign) NSTimeInterval leftTime;
@property(nonatomic, strong) CFDanmaku* danmaku;
@property(nonatomic, assign) NSInteger lineCount;

@end

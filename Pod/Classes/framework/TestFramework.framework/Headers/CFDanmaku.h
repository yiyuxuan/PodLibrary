//
//  CFDanmaku.h
//  DanmuDemo
//
//  Created by wangcheng on 15/8/6.
//  Copyright (c) 2015年 wangcheng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSInteger {
    CFDanmakuPositionNone = 0,
    CFDanmakuPositionCenterTop,
    CFDanmakuPositionCenterBottom
} CFDanmakuPosition;

@interface CFDanmaku : NSObject

// 对应视频的时间戳
@property(nonatomic, assign) NSTimeInterval timePoint;
// 弹幕内容
@property(nonatomic, copy) NSAttributedString* contentStr;
// 弹幕类型(如果不设置 默认情况下只是从右到左滚动)
@property(nonatomic, assign) CFDanmakuPosition position;
@end

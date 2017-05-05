//
//  CFDanmakuView.m
//  31- CFDanmakuDemo
//
//  Created by 于 传峰 on 15/7/9.
//  Copyright (c) 2015年 于 传峰. All rights reserved.
//

#import "CFDanmakuView.h"
#import "CFDanmakuInfo.h"



#define X(view) view.frame.origin.x
#define Y(view) view.frame.origin.y
#define Width(view) view.frame.size.width
#define Height(view) view.frame.size.height
#define Left(view) X(view)
#define Right(view) (X(view) + Width(view))
#define Top(view) Y(view)
#define Bottom(view) (Y(view) + Height(view))
#define CenterX(view) (Left(view) + Right(view))/2
#define CenterY(view) (Top(view) + Bottom(view))/2


@interface CFDanmakuView(){
    NSTimer* _timer;
}
@property(nonatomic ,strong) NSMutableArray *danmakus;
@property(nonatomic ,strong) NSMutableArray *currentDanmakus;
@property(nonatomic ,strong) NSMutableArray *subDanmakuInfos;
@property(nonatomic ,strong) NSMutableArray *labArr;
@property(nonatomic ,strong) NSMutableDictionary *linesDict;
@property(nonatomic ,strong) NSMutableDictionary *centerTopLinesDict;
@property(nonatomic ,strong) NSMutableDictionary *centerBottomLinesDict;
@property(nonatomic ,assign) float changeSize;
//@property(nonatomic, assign) BOOL centerPause;

@end

static NSTimeInterval const timeMargin = 0.5;
@implementation CFDanmakuView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - lazy
- (NSMutableArray *)labArr
{
    if (!_labArr) {
        _labArr = [[NSMutableArray alloc] init];
    }
    return _labArr;
}

- (NSMutableArray *)subDanmakuInfos
{
    if (!_subDanmakuInfos) {
        _subDanmakuInfos = [[NSMutableArray alloc] init];
    }
    return _subDanmakuInfos;
}

- (NSMutableDictionary *)linesDict
{
    if (!_linesDict) {
        _linesDict = [[NSMutableDictionary alloc] init];
    }
    return _linesDict;
}

- (NSMutableDictionary *)centerBottomLinesDict
{
    if (!_centerBottomLinesDict) {
        _centerBottomLinesDict = [[NSMutableDictionary alloc] init];
    }
    return _centerBottomLinesDict;
}

- (NSMutableDictionary *)centerTopLinesDict
{
    if (!_centerTopLinesDict) {
        _centerTopLinesDict = [[NSMutableDictionary alloc] init];
    }
    return _centerTopLinesDict;
}

- (NSMutableArray *)currentDanmakus
{
    if (!_currentDanmakus) {
        _currentDanmakus = [NSMutableArray array];
    }
    return _currentDanmakus;
}

#pragma mark - perpare
- (void)prepareDanmakus:(NSArray *)danmakus
{
    self.danmakus = [[danmakus sortedArrayUsingComparator:^NSComparisonResult(CFDanmaku* obj1, CFDanmaku* obj2) {
        if (obj1.timePoint > obj2.timePoint) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }] mutableCopy];
}

//定时器走的方法
- (void)getCurrentTime
{
//    NSLog(@"getCurrentTime---------");
    
    //如果视频处于加载中  返回
    if([self.delegate danmakuViewIsBuffering:self]) return;
    
    [self.subDanmakuInfos enumerateObjectsUsingBlock:^(CFDanmakuInfo* obj, NSUInteger idx, BOOL *stop) {
        NSTimeInterval leftTime = obj.leftTime;
        leftTime -= timeMargin;
        obj.leftTime = leftTime;
    }];
    
    [self.currentDanmakus removeAllObjects];
    //获取当前视频时间
    NSTimeInterval timeInterval = [self.delegate danmakuViewGetPlayTime:self];
    NSString* timeStr = [NSString stringWithFormat:@"%0.1f", timeInterval];
    timeInterval = timeStr.floatValue;
    
    [self.danmakus enumerateObjectsUsingBlock:^(CFDanmaku* obj, NSUInteger idx, BOOL *stop) {
        
//        NSLog(@"%f----%f--%zd", timeInterval, obj.timePoint, idx);

        //如果文件中的视频时间戳大于当前播放视频时间戳并且小于当前时间+0.5
        
        if (obj.timePoint >= timeInterval && obj.timePoint < timeInterval + timeMargin) {
            
            [self.currentDanmakus addObject:obj];
            
        }else if( obj.timePoint > timeInterval){
            
            *stop = YES;
            
        }
    }];
    
    if (self.currentDanmakus.count > 0) {
        for (CFDanmaku* danmaku in self.currentDanmakus) {
            //for循环弹幕走起
            [self playDanmaku:danmaku andIsSend:NO];
        }
    }
}

- (void)playDanmaku:(CFDanmaku *)danmaku andIsSend:(BOOL)isSend
{
    //创建一个lab
    UILabel* playerLabel = [[UILabel alloc] init];
    //设置lab
    playerLabel.attributedText = danmaku.contentStr;
    [playerLabel sizeToFit];
    [self addSubview:playerLabel];
    //将lab添加到一个容器中
    [self.labArr addObject:playerLabel];
    playerLabel.backgroundColor = [UIColor clearColor];
    if (isSend) {
        [playerLabel.layer setBorderWidth:0.5];
        [playerLabel.layer setBorderColor:[UIColor whiteColor].CGColor];
    }
//    self.playingLabel = playerLabel;
    //播放弹幕的类型
    switch (danmaku.position) {
        case CFDanmakuPositionNone:
            [self playFromRightDanmaku:danmaku playerLabel:playerLabel];
            break;
            
        case CFDanmakuPositionCenterTop:
        case CFDanmakuPositionCenterBottom:
            [self playCenterDanmaku:danmaku playerLabel:playerLabel];
            break;
            
        default:
            break;
    }
    
}

#pragma mark - center top \ bottom
- (void)playCenterDanmaku:(CFDanmaku *)danmaku playerLabel:(UILabel *)playerLabel
{
    NSAssert(self.centerDuration && self.maxCenterLineCount, @"如果要使用中间弹幕 必须先设置中间弹幕的时间及最大行数");
    
    CFDanmakuInfo* newInfo = [[CFDanmakuInfo alloc] init];
    newInfo.playLabel = playerLabel;
    newInfo.leftTime = self.centerDuration;
    newInfo.danmaku = danmaku;
    
    NSMutableDictionary *centerDict = nil;
    
    if (danmaku.position == CFDanmakuPositionCenterTop) {
        centerDict = self.centerTopLinesDict;
    }else{
        centerDict = self.centerBottomLinesDict;
    }
    
    NSInteger valueCount = centerDict.allKeys.count;
    if (valueCount == 0) {
        newInfo.lineCount = 0;
        [self addCenterAnimation:newInfo centerDict:centerDict];
        return;
    }
    for (int i = 0; i<valueCount; i++) {
        CFDanmakuInfo* oldInfo = centerDict[@(i)];
        if (!oldInfo) break;
        if (![oldInfo isKindOfClass:[CFDanmakuInfo class]]) {
            newInfo.lineCount = i;
            [self addCenterAnimation:newInfo centerDict:centerDict];
            break;
        }else if (i == valueCount - 1){
            if (valueCount < self.maxCenterLineCount) {
                newInfo.lineCount = i+1;
                [self addCenterAnimation:newInfo centerDict:centerDict];
            }else{
                [self.danmakus removeObject:danmaku];
                [playerLabel removeFromSuperview];
                [self.labArr removeObject:playerLabel];
                self.linesDict = nil;

                NSLog(@"中间弹幕太多--排不开了--------------------------");
            }
        }
    }

}

- (void)addCenterAnimation:(CFDanmakuInfo *)info  centerDict:(NSMutableDictionary *)centerDict
{
    
    UILabel* label = info.playLabel;
    NSInteger lineCount = info.lineCount;
    
    if (info.danmaku.position == CFDanmakuPositionCenterTop) {
        label.frame = CGRectMake((Width(self) - Width(label)) * 0.5, (self.lineHeight + self.lineMargin) * lineCount, Width(label), Height(label));
    }else{
        label.frame = CGRectMake((Width(self) - Width(label)) * 0.5, Height(self) - Height(label) - (self.lineHeight + self.lineMargin) * lineCount, Width(label), Height(label));
    }
    
    
    centerDict[@(lineCount)] = info;
    [self.subDanmakuInfos addObject:info];
    
    [self performCenterAnimationWithDuration:info.leftTime danmakuInfo:info];
}

- (void)performCenterAnimationWithDuration:(NSTimeInterval)duration danmakuInfo:(CFDanmakuInfo *)info
{
    UILabel* label = info.playLabel;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(_isPauseing) return ;
        
        if (info.danmaku.position == CFDanmakuPositionCenterBottom) {
            self.centerBottomLinesDict[@(info.lineCount)] = @(0);
        }else{
            self.centerTopLinesDict[@(info.lineCount)] = @(0);
        }
        
        [label removeFromSuperview];
        [self.subDanmakuInfos removeObject:info];
    });
}


#pragma mark - from right
- (void)playFromRightDanmaku:(CFDanmaku *)danmaku playerLabel:(UILabel *)playerLabel
{
    CFDanmakuInfo* newInfo = [[CFDanmakuInfo alloc] init];
    //将playerLabel的指针赋值于newInfo.playerLabel
    newInfo.playLabel = playerLabel;
    newInfo.leftTime = self.duration;
    newInfo.danmaku = danmaku;
    
    playerLabel.frame = CGRectMake(Width(self), 0, Width(playerLabel), Height(playerLabel));
    if (self.changeSize) {
            playerLabel.frame = CGRectMake(Width(self), 0, Width(playerLabel) * self.changeSize, Height(playerLabel) * self.changeSize);
        playerLabel.font = [UIFont systemFontOfSize:(15 * self.changeSize)];
    }

//    NSLog(@"self.linesDicts : %@", self.linesDict);

    //获取弹幕的行数
    NSInteger valueCount = self.linesDict.allKeys.count;

    //如果弹幕的行数为零  直接设置newInfo的行数为0
    if (valueCount == 0) {
        newInfo.lineCount = 0;
        //给newInfo添加动画
        [self addAnimationToViewWithInfo:newInfo];
        return;
    }
    
    //如果valueCount不为0
    for (int i = 0; i < valueCount; i++) {  
        CFDanmakuInfo* oldInfo = self.linesDict[@(i)];
        if (!oldInfo) break;   //如果不存在直接跳出循环体
        //检测老的lab和新的lab碰撞
        if (![self judgeIsRunintoWithFirstDanmakuInfo:oldInfo behindLabel:playerLabel]) {
            // 还是这一行出来
            newInfo.lineCount = i;  
            [self addAnimationToViewWithInfo:newInfo];
            //跳出循环体
            break;
            //   判断最后一个
        }else if (i == valueCount - 1){
            //如果lab数量在最大限制的范围内
            if (valueCount < self.maxShowLineCount) {
                //
                newInfo.lineCount = i+1;
                [self addAnimationToViewWithInfo:newInfo];
            }else{
                [self.danmakus removeObject:danmaku];
                [playerLabel removeFromSuperview];
                [self.labArr removeObject:playerLabel];
                self.linesDict = nil;
                NSLog(@"滚动弹幕太多--排不开了--------------------------");
            }
        }
    }
}

- (void)addAnimationToViewWithInfo:(CFDanmakuInfo *)info
{
    //创建个lab  并拿到info.playerLabel的指针
    UILabel* label = info.playLabel;
    //获取弹幕的行数
    NSInteger lineCount = info.lineCount;
    //计算书label的frame 
    label.frame = CGRectMake(Width(self), (self.lineHeight + self.lineMargin) * lineCount, Width(label), Height(label));
    //添加info到subDanmukuInfos
    [self.subDanmakuInfos addObject:info];
    //设置info到字典lineDicr  对应的键位lineCount
    self.linesDict[@(lineCount)] = info;
    //真正开始弹幕动画的时刻了
    [self performAnimationWithDuration:info.leftTime danmakuInfo:info];
}

- (void)performAnimationWithDuration:(NSTimeInterval)duration danmakuInfo:(CFDanmakuInfo *)info
{
    _isPlaying = YES;
    _isPauseing = NO;
    //取出label   
    UILabel* label = info.playLabel;
    
//    NSLog(@"lab.y : %ld  %.f", info.lineCount, Y(label));
    
    //计算出label的结束frame   -Width(label)的值就是label完全离开屏幕的界限
    
    CGRect endFrame = CGRectMake(-Width(label), Y(label), Width(label), Height(label));
//    NSLog(@"")
    //动画
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        //设置label的结束frame
        label.frame = endFrame;
    } completion:^(BOOL finished) {
        if (finished) {
            //动画结束移除label
            [label removeFromSuperview];
            //移除
            [self.subDanmakuInfos removeObject:info];
        }
    }];
}

// 检测碰撞 -- 默认从右到左
- (BOOL)judgeIsRunintoWithFirstDanmakuInfo:(CFDanmakuInfo *)info behindLabel:(UILabel *)last
{
    UILabel* firstLabel = info.playLabel;
    CGFloat firstSpeed = [self getSpeedFromLabel:firstLabel];
    CGFloat lastSpeed = [self getSpeedFromLabel:last];
    
//    CGRect firstFrame = info.labelFrame;
    CGFloat firstFrameRight = info.leftTime * firstSpeed;
    
    if(info.leftTime <= 1) return NO;
    
    if(Left(last) - firstFrameRight > 10) {
        
        if( lastSpeed <= firstSpeed)
        {
            return NO;
        }else{
            CGFloat lastEndLeft = Left(last) - lastSpeed * info.leftTime;
            if (lastEndLeft >  10) {
                return NO;
            }
        }
    }
    
    return YES;
}

// 计算速度
- (CGFloat)getSpeedFromLabel:(UILabel *)label
{
    return (self.bounds.size.width + label.bounds.size.width) / self.duration;
}

#pragma mark - 公共方法

- (BOOL)isPrepared
{
    NSAssert(self.duration && self.maxShowLineCount && self.lineHeight, @"必须先设置弹幕的时间\\最大行数\\弹幕行高");
    if (self.danmakus.count && self.lineHeight && self.duration && self.maxShowLineCount) {
        return YES;
    }
    return NO;
}

- (void)start
{
    //如果状态处于暂停
    if(_isPauseing) [self resume];
    
    if ([self isPrepared]) {
        if (!_timer) {
            _timer = [NSTimer timerWithTimeInterval:timeMargin target:self selector:@selector(getCurrentTime) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
            [_timer fire];
        }
    }
}
- (void)pause
{
    if(!_timer || !_timer.isValid) return;
    
    _isPauseing = YES;
    _isPlaying = NO;
    
    [_timer invalidate];
    _timer = nil;
    
    for (UILabel* label in self.subviews) {
        
        CALayer *layer = label.layer;
        CGRect rect = label.frame;
        if (layer.presentationLayer) {
            rect = ((CALayer *)layer.presentationLayer).frame;
        }
        label.frame = rect;
        [label.layer removeAllAnimations];
    }
}
- (void)resume
{
    if( ![self isPrepared] || _isPlaying || !_isPauseing) return;
    for (CFDanmakuInfo* info in self.subDanmakuInfos) {
        if (info.danmaku.position == CFDanmakuPositionNone) {
            [self performAnimationWithDuration:info.leftTime danmakuInfo:info];
        }else{
            _isPauseing = NO;
            [self performCenterAnimationWithDuration:info.leftTime danmakuInfo:info];
        }
    }
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeMargin * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self start];
    });
}
- (void)stop
{
    _isPauseing = NO;
    _isPlaying = NO;
    
    [_timer invalidate];
    _timer = nil;
    [self.danmakus removeAllObjects];
    self.linesDict = nil;
}

- (void)clear
{
    [_timer invalidate];
    _timer = nil;
    self.linesDict = nil;
    _isPauseing = YES;
    _isPlaying = NO;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)sendDanmakuSource:(CFDanmaku *)danmaku andIsSend:(BOOL)isSend
{
    [self playDanmaku:danmaku andIsSend:YES];
}

- (void)changeLabSize:(float)size
{
    self.changeSize = size;
}
@end

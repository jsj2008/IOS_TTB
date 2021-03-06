//
//  CustomAutoUpTextLable.m
//  NewsBannerDemo
//
//  Created by wen on 2016/10/25.
//  Copyright © 2016年 ssyzh. All rights reserved.
//

#import "CustomAutoUpTextLable.h"
#define kPointsNumber 100 // 即数字跳100次
#define kDurationTime 5.0 // 动画时间
#define kStartNumber  0   // 起始数字
#define kEndNumber    1000// 结束数字
@interface CustomAutoUpTextLable()

@property (nonatomic, assign) int pointsNumber;
@property (nonatomic, assign) NSTimeInterval durationTime;
@property (nonatomic, assign) float startNumber;
@property (nonatomic, assign) float endNumber;


@property (nonatomic, retain) NSMutableArray *numberPoints;//记录每次textLayer更改值的间隔时间及输出值。
@property (nonatomic, assign) float lastTime;
@property (nonatomic, assign) int indexNumber;

@property (nonatomic, assign) Point2D startPoint;
@property (nonatomic, assign) Point2D controlPoint1;
@property (nonatomic, assign) Point2D controlPoint2;
@property (nonatomic, assign) Point2D endPoint;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSTimeInterval timerSecond;
@end

@implementation CustomAutoUpTextLable
- (void)cleanUpValue {
    _lastTime = 0;
    _indexNumber = 0;
    self.text = [NSString stringWithFormat:@"%.2f",_startNumber];
}



- (void)dealloc
{
    [self invalidateTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)DidBecomeActive {
    [self.timer setFireDate:[NSDate date]];
}
- (void)DidEnterBackground {
    [self.timer setFireDate:[NSDate distantFuture]];
}



- (void)jumpNumberWithDuration:(NSTimeInterval)duration
                    fromNumber:(float)startNumber
                      toNumber:(float)endNumber
                animationBlock:(customeBlock)animationBlock
                      endBlock:(customeBlock)endBlock{
    _durationTime = duration;
    _startNumber = startNumber;
    _endNumber = endNumber;
    self.endblock = endBlock;
    self.animationBlock = animationBlock;
    [self cleanUpValue];
    [self initPoints];
    [self changeStringValue];
}







- (void)initPoints {
    // 贝塞尔曲线
    [self initBezierPoints];
    Point2D bezierCurvePoints[4] = {_startPoint, _controlPoint1, _controlPoint2, _endPoint};
    _numberPoints = [[NSMutableArray alloc] init];
    float dt;
    dt = 1.0 / (kPointsNumber - 1);
    for (int i = 0; i < kPointsNumber; i++) {
        Point2D point = PointOnCubicBezier(bezierCurvePoints, i*dt);
        float durationTime = point.x * _durationTime;
        float value = point.y * (_endNumber - _startNumber) + _startNumber;
        [_numberPoints addObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:durationTime], [NSNumber numberWithFloat:value], nil]];
    }
    
    
}

- (void)initBezierPoints {
    // 可到http://cubic-bezier.com自定义贝塞尔曲线
    
    _startPoint.x = 0;
    _startPoint.y = 0;
    
    _controlPoint1.x = 0.5;
    _controlPoint1.y = 0.5;
    
    _controlPoint2.x = 0.5;
    _controlPoint2.y = 0.5;
    
    _endPoint.x = 1;
    _endPoint.y = 1;
}



-(void)invalidateTimer{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)changeStringValue {
    
    if (_indexNumber >= kPointsNumber) {
        self.text = [NSString stringWithFormat:@"%.0f",_endNumber];
        if (self.animationBlock) {
            self.animationBlock();
        }
        if (self.endblock) {
            self.endblock();
        }
        [self invalidateTimer];
    }else{
        NSArray *pointValues = [_numberPoints objectAtIndex:_indexNumber];
        
        float value = [(NSNumber *)[pointValues objectAtIndex:1] intValue];
        self.text = [NSString stringWithFormat:@"%.0f",value];
        
        NSArray *pointValuesFirst = [_numberPoints objectAtIndex:_indexNumber];
        NSArray *pointValuesSecond = [_numberPoints objectAtIndex:_indexNumber+1<kPointsNumber?_indexNumber+1:_indexNumber];
        float secondTime = [(NSNumber *)[pointValuesSecond objectAtIndex:0] floatValue];
        float firstTime = [(NSNumber *)[pointValuesFirst objectAtIndex:0] floatValue];
        _timerSecond = secondTime - firstTime;
        
        
        self.timer =[NSTimer timerWithTimeInterval:_timerSecond target:self selector:@selector(changeStringValue) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        _indexNumber++;
        if (self.animationBlock) {
            self.animationBlock();
        }
        
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

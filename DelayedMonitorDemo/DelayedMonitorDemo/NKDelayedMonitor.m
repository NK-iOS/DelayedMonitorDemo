//
//  NKDelayedMonitor.m
//  DelayedMonitorDemo
//
//  Created by 聂宽 on 2019/8/17.
//  Copyright © 2019 聂宽. All rights reserved.
//

#import "NKDelayedMonitor.h"
#import "BSBacktraceLogger.h"
#import "UIViewController+FPS.h"

@interface NKDelayedMonitor ()

@property (nonatomic, assign) int timeoutCount;
@property (nonatomic, assign) CFRunLoopObserverRef observer;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, assign) CFRunLoopActivity activity;
@end

@implementation NKDelayedMonitor

+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _gateTime = 250;// 默认门阀时间为250ms
    }
    return self;
}

static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    NKDelayedMonitor *moniotr = (__bridge NKDelayedMonitor*)info;
    moniotr.activity = activity;
    dispatch_semaphore_t semaphore = moniotr.semaphore;
    dispatch_semaphore_signal(semaphore);
}

- (void)setGateTime:(NSInteger)gateTime {
    if (_gateTime && _gateTime >= 100) {
        _gateTime = gateTime;
    }
}

- (void)stopOnlineMonitor
{
    if (!_observer)
        return;
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);
    CFRelease(_observer);
    _observer = NULL;
}

- (void)startOnlineMonitor
{
    if (_observer)
        return;
    
    NSInteger countTimes = _gateTime / 50;
    
    // 信号,Dispatch Semaphore保证同步
    _semaphore = dispatch_semaphore_create(0);
    
    // 注册RunLoop状态观察
    CFRunLoopObserverContext context = {0,(__bridge void*)self,NULL,NULL};
    _observer = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                       kCFRunLoopAllActivities,
                                       YES,
                                       0,
                                       &runLoopObserverCallBack,
                                       &context);
    //将观察者添加到主线程runloop的common模式下的观察中
    CFRunLoopAddObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);
    
    // 在子线程监控时长 开启一个持续的loop用来进行监控
    __weak typeof(self) ws = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        while (YES)
        {
            //假定连续n次超时50ms认为卡顿(当然也包含了单次超时250ms)
            long st = dispatch_semaphore_wait(ws.semaphore, dispatch_time(DISPATCH_TIME_NOW, 50*NSEC_PER_MSEC));
            if (st != 0)
            {
                if (!ws.observer)
                {
                    ws.timeoutCount = 0;
                    ws.semaphore = 0;
                    ws.activity = 0;
                    return;
                }
                //两个runloop的状态，BeforeSources和AfterWaiting这两个状态区间时间能够检测到是否卡顿
                if (ws.activity==kCFRunLoopBeforeSources || ws.activity==kCFRunLoopAfterWaiting)
                {
                    if (++ws.timeoutCount < countTimes)
                        continue;
                    NSLog(@"啊啊啊啊, 卡主啦");
                    //打印堆栈信息
                    BSLOG_MAIN
                }//end activity
            }// end semaphore wait
            ws.timeoutCount = 0;
        }// end while
    });
}

- (void)startOfflineMonitor {
    [UIViewController displayFPS:YES];
}

@end

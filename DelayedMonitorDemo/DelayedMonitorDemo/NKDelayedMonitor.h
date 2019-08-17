//
//  NKDelayedMonitor.h
//  DelayedMonitorDemo
//
//  Created by 聂宽 on 2019/8/17.
//  Copyright © 2019 聂宽. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NKDelayedMonitor : NSObject

+ (instancetype)sharedInstance;

// 阀时(单位ms)
@property (nonatomic, assign) NSInteger gateTime;

- (void)startOnlineMonitor;
- (void)stopOnlineMonitor;

- (void)startOfflineMonitor;

@end

NS_ASSUME_NONNULL_END

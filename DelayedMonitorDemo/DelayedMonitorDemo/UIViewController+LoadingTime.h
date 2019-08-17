//
//  UIViewController+LoadingTime.h
//  RTperformance
//
//  Created by wen zhang on 2017/5/12.
//  Copyright © 2017年 Gwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (LoadingTime)

/**
 是否记录viewController 加载时间（viewDidLoad -> viewDidAppear）
 */
+ (void)recordViewLoadTime:(BOOL)yesOrNo;


@end

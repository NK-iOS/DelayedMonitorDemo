//
//  UIViewController+FPS.m
//  RTperformance
//
//  Created by wen zhang on 2017/5/10.
//  Copyright © 2017年 Gwen. All rights reserved.
//

#import "UIViewController+FPS.h"
#import "YYFPSLabel.h"
#import <objc/runtime.h>


static NSInteger kfpsLableTag = 123458;
static BOOL displayFPS = NO;

@implementation UIViewController (FPS)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self exchangeInstanceMethod:[self class] method1Sel:@selector(viewDidAppear:) method2Sel:@selector(rt_viewDidAppear:)];
    });
}

+ (void)displayFPS:(BOOL)yesOrNo {
    displayFPS = yesOrNo;
    if (displayFPS) {
        [self displayFPSLabel];
    }
}

+ (void)displayFPSLabel {
    id<UIApplicationDelegate> appDelegate = [UIApplication sharedApplication].delegate;
    UIWindow *window = [appDelegate window];
    YYFPSLabel *fpsLabel = [window viewWithTag:kfpsLableTag];
    if (fpsLabel) {
        [window bringSubviewToFront:fpsLabel];
    } else {
        fpsLabel = [[YYFPSLabel alloc] initWithFrame:CGRectMake(5, 15, window.bounds.size.width, 20)];
        fpsLabel.textColor = [UIColor redColor];
        fpsLabel.font = [UIFont systemFontOfSize:12];
        fpsLabel.tag = kfpsLableTag;
        [window addSubview:fpsLabel];
        [window bringSubviewToFront:fpsLabel];
    }
}

+ (void)exchangeInstanceMethod:(Class)anClass method1Sel:(SEL)method1Sel method2Sel:(SEL)method2Sel {
    
    
    Method originalMethod = class_getInstanceMethod(anClass, method1Sel);
    Method swizzledMethod = class_getInstanceMethod(anClass, method2Sel);
    
    BOOL didAddMethod =
    class_addMethod(anClass,
                    method1Sel,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(anClass,
                            method2Sel,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    }
    
    else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
}

#pragma mark - Method Swizzling

- (void)rt_viewDidAppear:(BOOL)animated
{
    [self rt_viewDidAppear:animated];
    
    if (displayFPS) {
        [[self class] displayFPSLabel];
    }
}


@end

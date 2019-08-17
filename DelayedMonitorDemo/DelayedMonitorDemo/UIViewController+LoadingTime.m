//
//  UIViewController+LoadingTime.m
//  RTperformance
//
//  Created by wen zhang on 2017/5/12.
//  Copyright © 2017年 Gwen. All rights reserved.
//

#import "UIViewController+LoadingTime.h"
#import <objc/runtime.h>

static CFTimeInterval rt_loadingBegin = 0;
static BOOL recordViewLoadTime = NO;

@implementation UIViewController (LoadingTime)

+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self exchangeInstanceMethod:[self class] method1Sel:@selector(viewDidLoad) method2Sel:@selector(rt_viewDidLoad)];
        [self exchangeInstanceMethod:[self class] method1Sel:@selector(viewDidAppear:) method2Sel:@selector(rt_ld_viewDidAppear:)];
    });
}

+ (void)recordViewLoadTime:(BOOL)yesOrNo {
    recordViewLoadTime = yesOrNo;
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

- (void)rt_viewDidLoad {
    [self rt_viewDidLoad];
    rt_loadingBegin = CACurrentMediaTime();

}

- (void)rt_ld_viewDidAppear:(BOOL)animated {
    [self rt_ld_viewDidAppear:animated];
    if (recordViewLoadTime) {
        [self.class recordViewLoadTime];
    }
}

+ (void)recordViewLoadTime {
    const char *className = class_getName(self.class);
    NSString *classNameStr = @(className);
    
    if ([self needRecordViewLoadTime:classNameStr]) {
        CFTimeInterval end = CACurrentMediaTime();
        NSLog(@"~~~~~~~~~~~%8.2f   ~~~~  className-> %@", (end - rt_loadingBegin) * 1000, classNameStr);
    }

}

+ (BOOL)needRecordViewLoadTime:(NSString *)className
{
    if ([className isEqualToString:@"UIInputWindowController"]) {
        return NO;
    } else if ([className isEqualToString:@"UINavigationController"]) {
        return NO;
    } else {
        return YES;
    }
}



@end

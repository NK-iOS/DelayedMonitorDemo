//
//  NBCrashReporter.h
//  Shopsicle
//
//  Created by Nanda Ballabh on 27/08/14.
//  Copyright (c) 2014 mulu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NBCrashReporter : NSObject

@property (strong , nonatomic) NSString * alertMessage;

@property (strong , nonatomic) NSString * alertTitle;

@property (assign , nonatomic) NSTimeInterval  alertDisplayTime;

+(NBCrashReporter*)initializeWithRootViewController:(id)rootViewController;

@end

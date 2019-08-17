//
//  NBCrashReporter.m
//  Shopsicle
//
//  Created by Nanda Ballabh on 27/08/14.
//  Copyright (c) 2014 mulu. All rights reserved.
//

#import "NBCrashReporter.h"
#import <MessageUI/MFMailComposeViewController.h>

#define kCrashLogDataKey @"CrashLogDataKey"
#define kCrashLogAlertKey @"kCrashLogAlertKey"
#define kdefaultAlertMessage @"Send these crash log to help developer to improve the app"
#define kdefaultAlertTitle @"Crash!!"
#define kdefaultAlertDisplayTime 1.0f

NS_ENUM(NSInteger, AlertButtonType)
{
    UIAlertViewCancelButton = 0,
    UIAlertViewOKButton
};

void addCrashReporter(NSException *exception) {
  
    NSString *appBuildVersion = [[[NSBundle mainBundle]infoDictionary]valueForKey:@"CFBundleVersion"];
    NSString *appVersion = [[[NSBundle mainBundle]infoDictionary]valueForKey:@"CFBundleShortVersionString"];
    NSString * appName = [[[NSBundle mainBundle]infoDictionary]valueForKey:@"CFBundleDisplayName"];
    NSArray *stack = [exception callStackSymbols];

    // Create exception dictionary
    NSString *description = [NSString stringWithFormat:@"*** Terminating app due to uncaught exception:%@ , Reasone: %@",exception.name,exception.reason];
   
    NSDictionary * crashLog = @{
                                @"Description":description,
                                @"AppName":appName,
                                @"Version":appVersion,
                                @"Build":appBuildVersion,
                                @"Time":[NSDate date],
                                @"ExceptionName":exception.name,
                                @"ExceptionReason":exception.reason,
                                @"ExceptionCallStack":stack
                                };
    NSData *crashData = [NSKeyedArchiver archivedDataWithRootObject:crashLog];
    // Now save this string and show alert at launch for asking do you want to send crash log
    
    [[NSUserDefaults standardUserDefaults] setObject:crashData forKey:kCrashLogDataKey];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kCrashLogAlertKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@interface NBCrashReporter ()

@property (strong , nonatomic) id rootViewController;

@end

@implementation NBCrashReporter

static NBCrashReporter *_instance = nil;

+(NBCrashReporter*)initializeWithRootViewController:(id)rootViewController {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if(_instance == nil)
            _instance = [[NBCrashReporter alloc]init];

    });
    _instance.rootViewController = rootViewController;
    return _instance;
}

-(id)init {
    self = [super init];
    if(self) {
        
        NSSetUncaughtExceptionHandler(&addCrashReporter);
        [self checkForCrashLogAlert];
        [self defaultSetup];
      }
    return self;
}

-(void)defaultSetup {
    self.alertMessage = kdefaultAlertMessage;
    self.alertTitle = kdefaultAlertTitle;
    self.alertDisplayTime = 1.0f;
  
}

-(void)checkForCrashLogAlert {
    
    BOOL showAlert = [[NSUserDefaults standardUserDefaults]boolForKey:kCrashLogAlertKey];
    if(showAlert) {
        [self performSelector:@selector(showAlertToSendCrashReport) withObject:nil afterDelay:self.alertDisplayTime];
    }
}


-(void)showAlertToSendCrashReport {
    
    
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:self.alertTitle message:self.alertMessage delegate:self cancelButtonTitle:@"Cencel" otherButtonTitles:@"Send", nil];
    
    // Show alertview on main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [alert show];
        
    });
   
}

#pragma mark UIAlertView Delegate Method 

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    

    switch (buttonIndex) {
            
        case UIAlertViewCancelButton:
            [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
            break;
            
        case UIAlertViewOKButton:
                [self sendCrashReport];
            break;
        default:
            break;
    }
        [self clearSavedCrashLog];
}

-(void)sendCrashReport {
    
    // Need to implement
    NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:kCrashLogDataKey];
    NSDictionary *crashData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSLog(@"%@",crashData);
   
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    filePath = [filePath stringByAppendingPathComponent:@"crashlog.txt"];
  
    [[NSString stringWithFormat:@"%@",crashData] writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:NULL] ;
   
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath isDirectory:NO];

    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]initWithActivityItems:@[fileUrl] applicationActivities:nil];
    [activityViewController setValue:@"Crash log " forKey:@"Subject"];
    activityViewController.excludedActivityTypes = @[
                                                     UIActivityTypePostToFacebook,
                                                     UIActivityTypePostToFlickr,
                                                     UIActivityTypePostToTencentWeibo,
                                                     UIActivityTypePostToTwitter,
                                                     UIActivityTypeMessage,
                                                     UIActivityTypeAssignToContact
                                                     ];
    [self.rootViewController presentViewController:activityViewController animated:YES completion:^{}];
    
}

-(void)clearSavedCrashLog {
    
    [[NSUserDefaults standardUserDefaults]setObject:[NSData data] forKey:kCrashLogDataKey];
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:kCrashLogAlertKey];
    [[NSUserDefaults standardUserDefaults]synchronize];

}

@end


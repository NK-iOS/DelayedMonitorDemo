//
//  ViewController.m
//  DelayedMonitorDemo
//
//  Created by 聂宽 on 2019/8/17.
//  Copyright © 2019 聂宽. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)delayOpt:(id)sender {
    for (int i = 0; i < 1; i++) {
        sleep(1);
    }
}

@end

//
//  ViewController.m
//  CircleTimer
//
// Created by Kirill Serebriakov on 9/25/14.
// Copyright (c) 2014 Appus Studio LLC. All rights reserved.
//

#import "ViewController.h"
#import "CircleTimer.h"

@interface ViewController () <CircleTimerDelegate>

@property (weak, nonatomic) IBOutlet CircleTimer *timeCircle;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.timeCircle.delegate = self;
    self.timeCircle.active = YES;
    [self updateCircleTimer];

}

- (void)updateCircleTimer {
    
    self.timeCircle.totalTime = 60;
    self.timeCircle.elapsedTime = 20;
}

#pragma mark - Action


- (IBAction)playStopClicked:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    if(sender.selected){
        if(self.timeCircle.didStart){
            [self.timeCircle resume];
        }else{
            [self.timeCircle start];
        }
    }else{
        [self.timeCircle stop];
    }
}




@end

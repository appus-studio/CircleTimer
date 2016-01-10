//
// Created by Kirill Serebriakov on 9/25/14.
// Copyright (c) 2014 Appus Studio LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CircleTimer;

@protocol CircleTimerDelegate <NSObject>
/**
* Alerts the delegate when the timer expires. At this point, counter animation is completed too.
*
* @param circleCounter the counter that just expired in time
*/
@optional
- (void)circleCounterTimeDidExpire:(CircleTimer *)circleCounter;

@end

IB_DESIGNABLE
@interface CircleTimer : UIView

/**
*   The receiver of all counter delegate callbacks.
*/
@property(nonatomic, strong) id <CircleTimerDelegate> delegate;

/** STATES
*   @didStart - Indicates if the circle counter did start the countdown and animation.
*   @isRunning - Indicates if the circle counter is currently counting down and animating.
*   @didFinish - Indicates if the circle counter finishing counting down and animating.
*   @active -
*/
@property(nonatomic, readonly) BOOL didStart;
@property(nonatomic, readonly) BOOL isRunning;
@property(nonatomic, getter=isActive) BOOL active;

/** APPEARANCE
*   @circleInactiveColor -
*   @circleBackgroundColor - The color of the circle indicating the expired amount of time
*   @circleBackgroundGradientRef - #optional
*   @circleColor - The color of the circle indicating the remaining amount of time
*   @circleGradientRef - #optional
*   @timeColor - Font color
*   @circleTimerWidth - The thickness of the circle color
*   @circleTimerBreakWidth - space between filled and unfilled part
*/
@property(nonatomic, strong) IBInspectable UIColor *inactiveColor;
@property(nonatomic, strong) IBInspectable UIColor *activeColor;
@property(nonatomic, strong) IBInspectable UIColor *pauseColor;
@property(nonatomic, strong) IBInspectable UIColor *fontColor;
@property(nonatomic) IBInspectable CGFloat thickness;
@property(nonatomic, strong) UIFont *font;
@property (assign) IBInspectable BOOL isBackwards;


/**  @elapsedTime - The amount of time that the timer has completed.
*                           It takes into account any stops/resumes
*                           and is updated in real time.
*/
@property(nonatomic) NSTimeInterval elapsedTime;
@property(nonatomic) NSTimeInterval totalTime;

@property(nonatomic) CGFloat offset;

/**
* Begins the count down and starts the animation. This has no effect if the counter
* isRunning. If a counter didFinish, you may restart it again by calling this method.
*
* @param seconds the length of the countdown timer
*/
- (void)start;

/**
* Pauses the countdown timer and stops animation. This only has an effect if the
* counter isRunning.
*/
- (void)stop;

/**
* Continues the countdown timer and resumes animation. This only has an effect if the
* counter is not running.
*/
- (void)resume;

/**
* Stops the counter and pauses animation as if it were at the initial, pre-started, state.
* After reset is called, didStart, isRunning, and didFinish will all be NO.
* You may start the timer again with start.
*/
- (void)reset;

- (void)baseInit;

@end

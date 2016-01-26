//
// Created by Kirill Serebriakov on 9/25/14.
// Copyright (c) 2014 Appus Studio LLC. All rights reserved.
//

#import "CircleTimer.h"

#define REFRESH_INTERVAL .015 // ~60 FPS

// Defaults
#define THIKNESS 8.0f

#define BGCOLOR  [UIColor colorWithRed:0.33 green:0.37 blue:0.42 alpha:1]
#define ACOLOR [UIColor colorWithRed:0.35 green:0.75 blue:0.74 alpha:1]
#define ICOLOR [UIColor colorWithRed:0.85 green:0.87 blue:0.9 alpha:1]
#define PCOLOR [UIColor colorWithRed:0.91 green:0.4 blue:0.51 alpha:1]

#define FONT UIFontAvenirNextBold(14)
#define FONT_COLOR [UIColor colorWithRed:0.34 green:0.78 blue:0.73 alpha:1]

#define OFFSET 0.015

@interface CircleTimer ()

@property(strong, nonatomic) NSTimer *timer;
@property(strong, nonatomic) NSDate *lastStartTime;

@property(assign, nonatomic) NSTimeInterval completedTimeUpToLastStop;

@property(weak, nonatomic) UILabel *timerLabel;
@end

@implementation CircleTimer {
    UIColor *_circleBackgroundColor;
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self baseInit];
    }
    
    return self;
}

- (void)baseInit {
    [self addBaseSubviews];
    
    super.backgroundColor = [UIColor clearColor];
    self.backgroundColor = BGCOLOR;
    self.activeColor = ACOLOR;
    self.inactiveColor = ICOLOR;
    self.pauseColor = PCOLOR;
    self.fontColor = FONT_COLOR;
    self.thickness = THIKNESS;
    self.font = FONT;
    self.completedTimeUpToLastStop = 0;
    
    self.elapsedTime = 0;
    self.offset = OFFSET;
    self.active = YES;
    self.isBackwards = NO;

}


- (BOOL)didStart {
    return self.timer != nil;
}


- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _circleBackgroundColor = backgroundColor;
}

- (UIColor *)backgroundColor {
    return _circleBackgroundColor;
}

- (void)setFontColor:(UIColor *)fontColor {
    _fontColor = fontColor;
    self.timerLabel.textColor = fontColor;
}

- (void)setFont:(UIFont *)font {
    _font = font;
    [self.timerLabel setFont:font];
}

- (void)setActive:(BOOL)active {
    _active = active;
    if (active) {
        [self updateTimerLabel:self.elapsedTime];
        self.timerLabel.textColor = self.fontColor;
    } else {
        [self updateTimerLabel:self.totalTime];
        self.timerLabel.textColor = self.backgroundColor;
    }
    [self setNeedsDisplay];
}


- (void)addBaseSubviews {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 0, 0)];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.adjustsFontSizeToFitWidth = YES;
    [label setText:@"00:00"];
    [self addSubview:label];
    
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    
    self.timerLabel = label;
}

- (void)setElapsedTime:(NSTimeInterval)elapsedTime {
    if (_elapsedTime != elapsedTime) {
        _elapsedTime = elapsedTime;
        [self updateTimerLabel:elapsedTime];
    }
}

- (void)updateTimerLabel:(NSTimeInterval)elapsedTime {
    int minutes;
    int seconds;
    
    if (self.isBackwards) {
        minutes = (int) ((self.totalTime - elapsedTime) / 60);
        seconds = (int) (self.totalTime - elapsedTime) % 60;
    } else {
        minutes = (int) elapsedTime / 60;
        seconds = (int) elapsedTime % 60;
    }

    NSString *time = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    [self.timerLabel setText:time];
}


- (void)start {
    if (_isRunning) return;
    if (self.didStart) {
        [self resume];
        return;
    }

    [CircleTimer validateInputTime:self.totalTime];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:REFRESH_INTERVAL target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];

    _isRunning = YES;
    _active = YES;

    self.lastStartTime = [NSDate date];
    self.completedTimeUpToLastStop = self.elapsedTime;

    [self.timer fire];
}

- (void)timerFired {
    if (!_isRunning) return;

    self.elapsedTime = (self.completedTimeUpToLastStop + [[NSDate date] timeIntervalSinceDate:self.lastStartTime]);

    // Check if timer has expired.
    if (self.elapsedTime > self.totalTime) {
        [self timerCompleted];
    }

    [self setNeedsDisplay];
}

- (void)resume {
    _isRunning = YES;
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    self.lastStartTime = now;
    [self.timer setFireDate:now];
}

- (void)stop {
    if (!_isRunning) return;
    _isRunning = NO;
    [self setNeedsDisplay];
    self.completedTimeUpToLastStop += [[NSDate date] timeIntervalSinceDate:self.lastStartTime];
    self.elapsedTime = self.completedTimeUpToLastStop;

    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)reset {
    [self.timer invalidate];
    self.timer = nil;

    self.elapsedTime = 0;
    _isRunning = NO;
    _active = YES;
}

#pragma mark - Private methods

+ (void)validateInputTime:(NSTimeInterval)time {
    if (time < 1) {
        [NSException raise:@"CircleTimer" format:@"inputted timer length, %li, must be a positive integer", (long) time];
    }
}

- (void)timerCompleted {
    [self.timer invalidate];

    _isRunning = NO;

    self.elapsedTime = self.totalTime;

    if ([self.delegate respondsToSelector:@selector(circleCounterTimeDidExpire:)]) {
        [self.delegate circleCounterTimeDidExpire:self];
    }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat radius = CGRectGetWidth(rect) / 2.0f - self.thickness / 2.0f;

    // Draw the background of the circle.
    CGContextSetLineWidth(context, self.thickness);

    CGContextBeginPath(context);
    CGFloat midX = CGRectGetMidX(rect);
    CGFloat midY = CGRectGetMidY(rect);
    CGContextAddArc(context, midX, midY, radius, 0, 2 * M_PI, 0);
    CGContextSetStrokeColorWithColor(context, [self.backgroundColor CGColor]);
    CGContextStrokePath(context);

    if (self.active) {
#if !TARGET_INTERFACE_BUILDER
        CGFloat angle;
        if (self.isBackwards) {
            angle = 2*M_PI - ((((CGFloat) self.elapsedTime) / (CGFloat) self.totalTime) * M_PI * 2);
        } else {
            angle =  (((CGFloat) self.elapsedTime) / (CGFloat) self.totalTime) * M_PI * 2;
        }
        if (self.isRunning) {
#else
CGFloat angle = M_PI;
            #endif
            CGContextBeginPath(context);
            CGContextAddArc(context, midX, midY, radius, -M_PI_2, angle - M_PI_2, 0);
            CGContextSetStrokeColorWithColor(context, [self.pauseColor CGColor]);
            CGContextStrokePath(context);
#if !TARGET_INTERFACE_BUILDER
        } else if (self.elapsedTime > 0) {
            CGContextBeginPath(context);
            CGContextAddArc(context, midX, midY, radius, angle - M_PI_2 + self.offset, -M_PI_2 - self.offset, 0);
            CGContextSetStrokeColorWithColor(context, [self.inactiveColor CGColor]);
            CGContextStrokePath(context);

            CGContextBeginPath(context);
            CGContextAddArc(context, midX, midY, radius, -M_PI_2, angle - M_PI_2, 0);
            CGContextSetStrokeColorWithColor(context, [self.activeColor CGColor]);
            CGContextStrokePath(context);
        }
#endif
    }

}


UIFont *UIFontAvenirNextBold(CGFloat size) {
    return [UIFont fontWithName:@"AvenirNext-Bold" size:size];
}

UIFont *UIFontAvenirNextRegular(CGFloat size) {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:size];
}

UIFont *UIFontAvenirNextMedium(CGFloat size) {
    return [UIFont fontWithName:@"AvenirNext-Medium" size:size];
}

@end

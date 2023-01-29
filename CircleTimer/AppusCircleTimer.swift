//
//  AppusCircleTimer.swift
//  AppusCircleTimer
//
//  Created by Sergey Sokoltsov on 11/30/16.
//  Copyright © 2016 Sergey Sokoltsov. All rights reserved.
//

import Foundation
import UIKit

let REFRESH_INTERVAL = 0.015 // ~60 FPS

public protocol AppusCircleTimerDelegate: NSObjectProtocol {
    /**
     * Alerts the delegate when the timer expires. At this point, counter animation is completed too.
     *
     * @param circleCounter the counter that just expired in time
     */
    func circleCounterTimeDidExpire(circleTimer: AppusCircleTimer)
}

func UIFontAvenirNextBold(size: CGFloat) -> UIFont {
    return UIFont(name: "AvenirNext-Bold", size: size)!
}

func UIFontAvenirNextRegular(size: CGFloat) -> UIFont {
    return UIFont(name: "AvenirNext-Regular", size: size)!
}

func UIFontAvenirNextMedium(size: CGFloat) -> UIFont {
    return UIFont(name: "AvenirNext-Medium", size: size)!
}

@IBDesignable
public class AppusCircleTimer: UIView {
    // Defaults
    let THICKNESS: CGFloat = 8.0
    
    let BGCOLOR = UIColor(red:0.33, green:0.37, blue:0.42, alpha:1)
    let ACOLOR = UIColor(red:0.35, green:0.75, blue:0.74, alpha:1)
    let ICOLOR = UIColor(red:0.85, green:0.87, blue:0.9, alpha:1)
    let PCOLOR = UIColor(red:0.91, green:0.4, blue:0.51, alpha:1)
    
    let FONT = UIFontAvenirNextBold(size:14.0)
    let FONT_COLOR = UIColor(red:0.34, green:0.78, blue:0.73, alpha:1)
    let OFFSET : CGFloat = 0.015
    
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        baseInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        baseInit()
    }
    
    
    /**
     *   The receiver of all counter delegate callbacks.
     */
    public weak var delegate : AppusCircleTimerDelegate?
    
    /** STATES
     *   @didStart - Indicates if the circle counter did start the countdown and animation.
     *   @isRunning - Indicates if the circle counter is currently counting down and animating.
     *   @didFinish - Indicates if the circle counter finishing counting down and animating.
     *   @active -
     */
    public var didStart : Bool {
        return timer != nil
    }
    private(set) var isRunning = false
    public var isActive = true {
        didSet (newValue) {
            if newValue {
                self.updateTimerLabel(timeInterval: self.elapsedTime)
                timerLabel?.textColor = self.fontColor
            } else {
                self.updateTimerLabel(timeInterval: self.totalTime)
                timerLabel?.textColor = self.backgroundColor
            }
            self.setNeedsDisplay()
        }
    }
    
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
    
    @IBInspectable public var inactiveColor : UIColor?
    @IBInspectable public var activeColor : UIColor?
    @IBInspectable public var pauseColor : UIColor?
    @IBInspectable public var fontColor : UIColor? {
        didSet(newValue) {
            timerLabel?.textColor = newValue
        }
    }
    @IBInspectable public var thickness : CGFloat = 0.0
    public var font : UIFont? {
        didSet(newValue) {
            timerLabel?.font = newValue
        }
    }
    @IBInspectable public var isBackwards = false
    
    /**  @elapsedTime - The amount of time that the timer has completed.
     *                           It takes into account any stops/resumes
     *                           and is updated in real time.
     */
    public var elapsedTime : TimeInterval = 0.0 {
        didSet(newValue) {
            updateTimerLabel(timeInterval: newValue)
        }
    }
    public var totalTime : TimeInterval = 0.0
    var offset : CGFloat = 0.0

    private var timer : Timer?
    private var lastStartTime : Date?
    private var completedTimeUpToLastStop : TimeInterval = 0.0
    weak var timerLabel : UILabel?
    var circleBackgroundColor : UIColor?
    
    
    /**
     * Begins the count down and starts the animation. This has no effect if the counter
     * isRunning. If a counter didFinish, you may restart it again by calling this method.
     *
     * @param seconds the length of the countdown timer
     */
    public func start() {
        if isRunning {
            return
        }
        if didStart {
            self.resume()
            return
        }
        if self.elapsedTime == totalTime {
            self.reset()
        }
        AppusCircleTimer.validateInputTime(self.totalTime)
        timer = Timer.scheduledTimer(timeInterval:REFRESH_INTERVAL,
                                     target: self,
                                     selector:#selector(AppusCircleTimer.timerFired),
                                     userInfo: nil,
                                     repeats: true);
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
        isRunning = true
        isActive = true
        
        lastStartTime = Date()
        completedTimeUpToLastStop = elapsedTime
        timer?.fire()
    }

    @objc private func timerFired() {
        if !isRunning {
            return
        }
    
        elapsedTime = (completedTimeUpToLastStop + Date().timeIntervalSince(lastStartTime!))
        // Check if timer has expired.
        if self.elapsedTime > totalTime {
            self.timerCompleted()
        }
        setNeedsDisplay()
    }

    private func timerCompleted() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        elapsedTime = totalTime
        delegate?.circleCounterTimeDidExpire(circleTimer: self)
    }
    
    /**
     * Pauses the countdown timer and stops animation. This only has an effect if the
     * counter isRunning.
     */
    public func stop() {
        if !isRunning {
            return
        }
        isRunning = false
        setNeedsDisplay()
        completedTimeUpToLastStop += Date().timeIntervalSince(lastStartTime!)
        elapsedTime = completedTimeUpToLastStop
        
        timer?.fireDate = Date.distantFuture
    }

    /**
     * Continues the countdown timer and resumes animation. This only has an effect if the
     * counter is not running.
     */
    public func resume() {
        isRunning = true
        lastStartTime = Date()
        timer?.fireDate = lastStartTime!
    }
    
    /**
     * Stops the counter and pauses animation as if it were at the initial, pre-started, state.
     * After reset is called, didStart, isRunning, and didFinish will all be NO.
     * You may start the timer again with start.
     */
    public func reset() {
        timer?.invalidate()
        timer = nil
        elapsedTime = 0;
        isRunning = false
        isActive = true
    }
    
    func baseInit() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
        addBaseSubviews()
        
        super.backgroundColor = UIColor.clear
        backgroundColor = BGCOLOR
        activeColor = ACOLOR
        inactiveColor = ICOLOR
        pauseColor = PCOLOR
        fontColor = FONT_COLOR
        thickness = THICKNESS
        font = FONT
        completedTimeUpToLastStop = 0.0
        offset = OFFSET
        isActive = true
    }

    private func addBaseSubviews() {
        let label = UILabel(frame: self.bounds.insetBy(dx: 0, dy: 0))
        label.textAlignment = NSTextAlignment.center
        label.adjustsFontSizeToFitWidth = true
        label.text = "00:00"
        self .addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        self.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0))
        timerLabel = label
        
    }
    
    override public var backgroundColor: UIColor? {
        set(newValue) {
            circleBackgroundColor = newValue
        }
        get {
            return circleBackgroundColor
        }
    }
    
    private func updateTimerLabel(timeInterval : TimeInterval) {
        var minutes = 0
        var seconds = 0
        if self.isBackwards {
            minutes = Int((totalTime - elapsedTime) / 60);
            seconds = Int((totalTime - elapsedTime).truncatingRemainder(dividingBy: 60));
        } else {
            minutes = Int(elapsedTime / 60);
            seconds = Int(elapsedTime.truncatingRemainder(dividingBy: 60));
        }
        let string = String.init(format:"%02d:%02d", minutes, seconds)
        timerLabel?.text = string
    }
    
    class func validateInputTime(_ timeInterval:TimeInterval) {
        if (timeInterval < 1) {
            NSException.raise(NSExceptionName("CircleTimer"), format: "inputted timer length, %@, must be a positive integer", arguments: getVaList([String(timeInterval)]))
        }
    }
    
    override public func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let radius = rect.width / 2.0 - thickness / 2.0
        
        // Draw the background of the circle.
        context?.setLineWidth(thickness)
        
        context?.beginPath()
        let midX = rect.midX
        let midY = rect.midY
        let midPoint = CGPoint.init(x: midX, y: midY)
        
        let endAngle = CGFloat (2.0 * Double.pi)
        
        context?.addArc(center:midPoint ,
                        radius: radius,
                        startAngle: 0,
                        endAngle:endAngle, clockwise:false)
        context?.setStrokeColor((backgroundColor?.cgColor)!)
        context?.strokePath()
        
        if isActive {
            #if !TARGET_INTERFACE_BUILDER
                var angle : CGFloat
                if isBackwards {
                    angle = CGFloat((2.0 * Double.pi) - ((elapsedTime/totalTime) * Double.pi * 2.0))
                } else {
                    angle = CGFloat((elapsedTime/totalTime) * Double.pi * 2.0)
                }
                if isRunning {
                    context?.beginPath()
                    context?.addArc(center: midPoint,
                                    radius: radius,
                                    startAngle: -CGFloat(Double.pi/2),
                                    endAngle: angle - CGFloat(Double.pi/2),
                                    clockwise: false)
                    context?.setStrokeColor((pauseColor?.cgColor)!)
                    context?.strokePath()
                } else if elapsedTime > 0 {
                    context?.beginPath()
                    context?.addArc(center: midPoint,
                                    radius: radius,
                                    startAngle: angle - CGFloat(Double.pi/2) + offset,
                                    endAngle: -CGFloat(Double.pi/2) - self.offset,
                                    clockwise: false)
                    context?.setStrokeColor((inactiveColor?.cgColor)!)
                    context?.strokePath()
                    
                    context?.beginPath()
                    context?.addArc(center: midPoint,
                                    radius: radius,
                                    startAngle: -CGFloat(Double.pi/2),
                                    endAngle: angle - CGFloat(Double.pi/2),
                                    clockwise: false)
                    context?.setStrokeColor((activeColor?.cgColor)!)
                    context?.strokePath()
                }
            #else
                var angle = CGFloat(Double.pi)
                context?.beginPath()
                context?.addArc(center: midPoint,
                                radius: radius,
                                startAngle: -CGFloat(Double.pi/2),
                                endAngle: angle - CGFloat(Double.pi/2),
                                clockwise: false)
                context?.setStrokeColor((pauseColor?.cgColor)!)
                context?.strokePath()
                
            #endif
        }
    }
}

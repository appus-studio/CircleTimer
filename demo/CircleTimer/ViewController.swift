//
//  ViewController.swift
//  CircleTimer
//
//  Created by Sergey Sokoltsov on 11/30/16.
//  Copyright © 2016 Sergey Sokoltsov. All rights reserved.
//

import UIKit
import AppusCircleTimer

class ViewController: UIViewController, AppusCircleTimerDelegate {
    @IBOutlet weak var circleTimer : AppusCircleTimer?
    @IBOutlet weak var startButton : UIButton?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        circleTimer?.delegate = self
        circleTimer?.isBackwards = true
        circleTimer?.isActive = true
        circleTimer?.totalTime = 60
        circleTimer?.elapsedTime = 58
        // Do any additional setup after loading the view, typically from a nib.
    }

    func circleCounterTimeDidExpire(circleTimer: AppusCircleTimer) {
        startButton?.isSelected = false
    }


    @IBAction func startStopClicked(sender:UIButton) {
        sender.isSelected = !sender.isSelected;
        if(sender.isSelected){
            if(circleTimer?.didStart)!{
                circleTimer?.resume()
            } else {
                circleTimer?.start()
            }
        }else{
            circleTimer?.stop()
        }
    }
    
    @IBAction func resetClicked(_ sender: Any) {
        circleTimer?.reset()
        circleTimer?.elapsedTime = 58
        startButton?.isSelected = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


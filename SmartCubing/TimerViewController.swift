//
//  TimerViewController.swift
//  SmartCubing
//
//  Created by Michael Lavina on 9/5/15.
//  Copyright (c) 2015 Swiftoid. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController {
    var timing = false
    var startTime = NSTimeInterval()
    var timer = NSTimer()
    
    var startTouchTime = NSDate.timeIntervalSinceReferenceDate()
    
    var colorTimer: NSTimer = NSTimer()
    
    @IBOutlet weak var timerLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {

        if(!timing) {
            startTouchTime = NSDate.timeIntervalSinceReferenceDate()
            self.view.backgroundColor = UIColor(red: 212.0/255, green: 49.0/255, blue: 49.0/255, alpha: 1)
            colorTimer = NSTimer.scheduledTimerWithTimeInterval(0.75, target: self, selector:  Selector("turnGreen"), userInfo: nil, repeats: false)

        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if(!timing) {
        var endTouchTime = NSDate.timeIntervalSinceReferenceDate()
        var touchDuration = endTouchTime - startTouchTime
        if(touchDuration > 0.75) {
            startTimer()
        }
        } else {
            stopTimer()
        }
        self.view.backgroundColor = UIColor.whiteColor()
        
    }
    
    func turnGreen () {
        var touchTimeSoFar = NSDate.timeIntervalSinceReferenceDate() - startTouchTime
        if(touchTimeSoFar > 0.75) {
        self.view.backgroundColor = UIColor(red: 14.0/255, green: 196.0/255, blue: 29.0/255, alpha: 1)
        } else {
            colorTimer = NSTimer.scheduledTimerWithTimeInterval(0.75 - touchTimeSoFar, target: self, selector: Selector("turnGreen"), userInfo: nil, repeats: false)
        }
    }
    // Updates display label
    func updateTime() {
        if(timing) {
        var curTime = NSDate.timeIntervalSinceReferenceDate()
        var elapsedTime = curTime - startTime
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        
        let seconds = UInt8(elapsedTime)
        elapsedTime -= NSTimeInterval(seconds)
        
        let fraction = UInt8(elapsedTime * 100)
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        var timeText = String(seconds) + "." + strFraction
        if(minutes > 0) {
            timeText = String(minutes) + ":" + timeText
        }
        timerLabel.text = timeText
    }
    }
    
    func startTimer() {
        timing = true
        let aSelector : Selector = "updateTime"
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
        startTime = NSDate.timeIntervalSinceReferenceDate()
    }
    
    func stopTimer() {
        timing = false
        timer.invalidate()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

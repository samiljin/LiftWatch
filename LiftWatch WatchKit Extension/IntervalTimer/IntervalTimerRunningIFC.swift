//
//  IntervalTimerRunningIFC.swift
//  LiftWatch WatchKit Extension
//
//  Created by Sami Iljin on 11/12/2017.
//  Copyright © 2017 Sami Iljin. All rights reserved.
//

import Foundation
import WatchKit

class IntervalTimerRunningIFC : WKInterfaceController {
    
    enum CurrentTimerType {
        case workout, rest
    }
    
    @IBOutlet var timeLeftLabel: WKInterfaceLabel!
    
    deinit {
        timer?.invalidate()
    }

    override func awake(withContext context: Any?) {
        guard let intervalTimes = context as? IntervalTimes else { fatalError() }
        
        self.intervalTimes = intervalTimes
        showCountdown()
    }
    
    private func showCountdown() {
        var count = 0
        let countTo = countdown.count

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
            [unowned self] timer in
            self.timeLeftLabel.setText(self.countdown[count])
            
            count += 1
            if count == countTo {
                timer.invalidate()
                self.startTimer()
            }
        }
    }
    
    private func startTimer() {
        vibrate()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
            [unowned self] _ in
            
            self.updateTimeLeftLabel()
            
            switch self.currentTimerType {
            case .workout:
                self.elapsedTimes.workoutTime += 1
            case .rest:
                self.elapsedTimes.restTime += 1
            }
        
            self.updateCurrentTimerType()
        }
    }
    
    private func updateTimeLeftLabel() {
        var timeLeft = 0

        switch currentTimerType {
        case .workout:
            timeLeft = intervalTimes!.workoutTime - elapsedTimes.workoutTime
        case .rest:
            timeLeft = intervalTimes!.restTime - elapsedTimes.restTime
        }

        timeLeftLabel.setText("\(timeLeft)")
    }
    
    private func updateCurrentTimerType() {
        switch currentTimerType {
        case .workout:
            guard intervalTimes!.workoutTime - elapsedTimes.workoutTime == 0 else { return }

            elapsedTimes.workoutTime = 0
            currentTimerType = .rest
            vibrate()
        case .rest:
            guard intervalTimes!.restTime - elapsedTimes.restTime == 0 else { return }

            elapsedTimes.restTime = 0
            currentTimerType = .workout
            vibrate()
        }
    }
    
    private func vibrate() {
        WKInterfaceDevice.current().play(.failure)
    }
    
    private var countdown: [String] = ["☝🏻", "✌🏻", "💪🏻"]
    private var currentTimerType: CurrentTimerType = .workout
    private weak var timer: Timer?
    private var intervalTimes: IntervalTimes?
    private var elapsedTimes: IntervalTimes = (workoutTime: 0, restTime: 0)
}

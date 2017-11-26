//
//  HeartRateIFC.swift
//  LiftWatch
//
//  Created by Sami Iljin on 11/11/2017.
//  Copyright © 2017 Sami Iljin. All rights reserved.
//

import WatchKit
import HealthKit
import Foundation


class HeartRateIFC: WKInterfaceController {

    @IBOutlet var elapsedTimeLabel: WKInterfaceLabel!
    @IBOutlet var hearthRateLabel: WKInterfaceLabel!
    @IBOutlet var restTimerLabel: WKInterfaceLabel!
    
    @IBAction func restTimerTapped(_ sender: Any) {
        restTimerActive = !restTimerActive
        
        if !restTimerActive {
            elapsedRestTime = 0
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        removeTitle()
        becomeCurrentPage()
        startWorkoutSession()
        
        WKExtension.shared().delegate = self
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
            [unowned self] _ in
            self.elapsedTimeInSeconds += 1
            
            if self.restTimerActive {
                self.elapsedRestTime += 1
            }
            
            self.updateTimeLabels()
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    private func startWorkoutSession() {
        do {
            workoutSession = try HKWorkoutSession(configuration: workoutConfig)
        } catch {
            fatalError("Could not create workoutsession")
        }

        workoutSession!.delegate = self
        HealthManager.shared.start(session: workoutSession!)
    }
    
    private func updateTimeLabels() {
        let (hours, minutes, seconds) = elapsedTimeInSeconds.secondsToElapsedTimeFormat()
        let formattedTime = String(format: "%02i:%02i:%02i", hours, minutes, seconds)
        elapsedTimeLabel.setText(formattedTime)
    
        let (restHours, restMinutes, restSeconds) = elapsedRestTime.secondsToElapsedTimeFormat()
        let formatted = String(format: "%02i:%02i:%02i", restHours, restMinutes, restSeconds)
        restTimerLabel.setText(formatted)
    }
    
    private func updateBpmLabel(quantity: HKQuantity) {
        let bpm = Int(quantity.doubleValue(for: HKUnit(from: "count/min")))
        self.hearthRateLabel.setText("\(bpm)")
    }
    
    fileprivate func observeHearthRate() {
        HealthManager.shared.startHearthRateQuery(from: Date()) {
            [unowned self] samples in
            
            guard let quantity = samples.last?.quantity else { return }
            self.updateBpmLabel(quantity: quantity)
        }
    }
    
    private var workoutSession: HKWorkoutSession?
    private var workoutConfig: HKWorkoutConfiguration {
        let config = HKWorkoutConfiguration()
        config.activityType = .traditionalStrengthTraining
        config.locationType = .indoor
        return config
    }
    
    private var elapsedTimeInSeconds = 0
    private var elapsedRestTime = 0
    private var restTimerActive = false
}

extension HeartRateIFC : HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        if toState == .running {
            observeHearthRate()
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension HeartRateIFC : WKExtensionDelegate {
    func applicationDidFinishLaunching() {
        print("DidFinishLaunching")
    }
    
    func applicationDidBecomeActive() {
        print("DidBecomeActive")
    }
    
    func applicationWillResignActive() {
        print("WillResignActive")
    }
    
    func applicationWillEnterForeground() {
        print("WillEnterForeground")
    }
    
    func applicationDidEnterBackground() {
        print("DidEnterBackground")
    }
}




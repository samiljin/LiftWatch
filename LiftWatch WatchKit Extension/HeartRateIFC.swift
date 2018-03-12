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

    @IBOutlet var heartIcon: WKInterfaceImage!
    @IBOutlet var elapsedTimeLabel: WKInterfaceLabel!
    @IBOutlet var hearthRateLabel: WKInterfaceLabel!
    @IBOutlet var restTimerLabel: WKInterfaceLabel!
    @IBOutlet var caloriesBurnedLabel: WKInterfaceLabel!

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
            [weak self] _ in
            guard self != nil else { return }

            self!.elapsedTimeInSeconds += 1
            
            if self!.restTimerActive {
                self!.elapsedRestTime += 1
            }
            
            self!.updateTimeLabels()
        }
        
        HealthManager.shared.startKcalQuery()
        HealthManager.shared.kcalObserver.onCaloriesUpdated = {
            [weak self] activeCalories in
            self?.caloriesBurnedLabel.setText("\(activeCalories)")
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // TODO: This is not needed. Only for simulator dev purposes.
        animateHeartWith(bpm: 60)
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
    
    @IBAction func saveItemTapped() {
        endWorkout(save: true)
    }
    
    @IBAction func deleteItemTapped() {
        endWorkout(save: false)
    }
    
    private func endWorkout(save: Bool) {
        HealthManager.shared.end(session: workoutSession!)
        
        if save {
            HealthManager.shared.saveWorkout()
        }
            
        dismiss()
    }
    
    private func animateHeartWith(bpm: Int) {
//        let duration: Double = 60.0 / Double(bpm)
//        let growDuration: Double = duration * 0.3
//        let normalizeDuration: Double = duration * 0.7
//
//        animate(withDuration: growDuration) {
//            [unowned self] in
//            self.heartIcon.setRelativeWidth(1, withAdjustment: 0)
//            DispatchQueue.main.asyncAfter(deadline: .now() + growDuration) {
//                self.animate(withDuration: normalizeDuration) {
//                    [unowned self] in
//                    self.heartIcon.setRelativeWidth(0.7, withAdjustment: 0)
//                    DispatchQueue.main.asyncAfter(deadline: .now() + normalizeDuration) {
//                        [unowned self] in
//                        self.animateHeartWith(bpm: self.currentBpm)
//                    }
//                }
//            }
//        }
    }
    
    private func updateTimeLabels() {
        let (hours, minutes, seconds) = elapsedTimeInSeconds.secondsToElapsedTimeFormat()
        let formattedTime = String(format: "%02i:%02i:%02i", hours, minutes, seconds)
        elapsedTimeLabel.setText(formattedTime)
    
        let (restHours, restMinutes, restSeconds) = elapsedRestTime.secondsToElapsedTimeFormat()
        let formatted = String(format: "%02i:%02i:%02i", restHours, restMinutes, restSeconds)
        restTimerLabel.setText(formatted)
    }
    
    fileprivate func observeHearthRate() {
        HealthManager.shared.startHearthRateQuery(from: Date()) {
            [weak self] samples in
            guard let quantity = samples.last?.quantity else { return }
            self?.currentBpm = Int(quantity.doubleValue(for: HKUnit(from: "count/min")))
        }
    }
    
    private var workoutSession: HKWorkoutSession?
    private var workoutConfig: HKWorkoutConfiguration {
        let config = HKWorkoutConfiguration()
        config.activityType = .traditionalStrengthTraining
        config.locationType = .indoor
        return config
    }
    
    private var currentBpm = 60 {
        didSet {
            self.hearthRateLabel.setText("\(currentBpm)")
        }
    }
    private var elapsedTimeInSeconds = 0
    private var elapsedRestTime = 0
    private var restTimerActive = false
}

extension HeartRateIFC : HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        if toState == .running {
            observeHearthRate()
            HealthManager.shared.startKcalQuery()
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension HeartRateIFC : WKExtensionDelegate {
    func applicationDidFinishLaunching() {
//        print("DidFinishLaunching")
    }
    
    func applicationDidBecomeActive() {
//        print("DidBecomeActive")
    }
    
    func applicationWillResignActive() {
//        print("WillResignActive")
    }
    
    func applicationWillEnterForeground() {
//        print("WillEnterForeground")
    }
    
    func applicationDidEnterBackground() {
//        print("DidEnterBackground")
    }
}




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
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        startWorkoutSession()
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
    
    fileprivate func observeHearthRate() {
        HealthManager.shared.startHearthRateQuery(from: Date()) {
            samples in
            
            guard let quantity = samples.last?.quantity else { return }
            
            let hr = HKUnit(from: "count/min")
            
            print(quantity.doubleValue(for: hr))
        }
    }
    
    private var workoutSession: HKWorkoutSession?
    private var workoutConfig: HKWorkoutConfiguration {
        let config = HKWorkoutConfiguration()
        config.activityType = .traditionalStrengthTraining
        config.locationType = .indoor
        return config
    }
    
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

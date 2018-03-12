//
//  KcalObserver.swift
//  LiftWatch WatchKit Extension
//
//  Created by Sami Iljin on 15/02/2018.
//  Copyright © 2018 Sami Iljin. All rights reserved.
//

import Foundation
import HealthKit

class KcalObserver {
    
    var onCaloriesUpdated: ((Int) -> ())?
    
    init(updateInterval: Double, healthStore: HKHealthStore) {
        self.updateInterval = updateInterval
        self.healthStore = healthStore
    }
    
    func start() {
        self.lastUpdatesEndedAt = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) {
            [weak self] _ in
            guard self != nil else { return }
            
            self?.queryCalories()
        }
    }
    
    func stop() {
        timer?.invalidate()
    }
    
    func getActiveCaloriesBurned() -> Double {
        return activeCaloriesBurned
    }
    
    private func queryCalories() {
        let endDate = Date()
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        let kcalPredicate = HKQuery.predicateForSamples(withStart: lastUpdatesEndedAt!, end: endDate, options: HKQueryOptions.strictStartDate)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [kcalPredicate, devicePredicate])
        
        let query = HKSampleQuery(sampleType: self.quantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: []) {
            [unowned self] query, results, error in
            guard let samples = results as? [HKQuantitySample] else { return }
            
            for sample in samples {
                self.activeCaloriesBurned += sample.quantity.doubleValue(for: self.unit)
            }
        }
        
        healthStore.execute(query)
        
        onCaloriesUpdated?(Int(activeCaloriesBurned))
        self.lastUpdatesEndedAt = endDate
    }
    
    private var timer: Timer?
    private var lastUpdatesEndedAt: Date?
    private var activeCaloriesBurned = 0.0
    
    private let updateInterval: Double
    private let healthStore: HKHealthStore
    private let unit = HKUnit.kilocalorie()
    private let quantityType = HKQuantityType.kcal
    
}

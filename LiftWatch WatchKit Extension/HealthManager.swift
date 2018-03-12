//
//  HealthManager.swift
//  LiftWatch WatchKit Extension
//
//  Created by Sami Iljin on 13/11/2017.
//  Copyright © 2017 Sami Iljin. All rights reserved.
//

import Foundation
import HealthKit

class HealthManager {
    
    let kcalObserver: KcalObserver
    typealias ResultHandler = ((HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void)
    
    public static let shared = HealthManager()
    
    func isHearthRateAccessGranted() -> Bool {
        let status = healthStore.authorizationStatus(for: HKQuantityType.hearthRate)
        return status == .sharingAuthorized
    }
    
    func isKcalAccessGranted() -> Bool {
        let status = healthStore.authorizationStatus(for: HKQuantityType.kcal)
        return status == .sharingAuthorized
    }
    
    func start(session: HKWorkoutSession) {
        self.workoutSession = session
        healthStore.start(session)
    }

    func end(session: HKWorkoutSession) {
        kcalObserver.stop()
        healthStore.end(session)
    }
    
    func saveWorkout() {
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        let kcalPredicate = HKQuery.predicateForSamples(withStart: workoutSession?.startDate, end: workoutSession?.endDate, options: HKQueryOptions.strictStartDate)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [kcalPredicate, devicePredicate])
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        let query = HKSampleQuery(sampleType: HKQuantityType.kcal, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sort]) {
            [unowned self] query, results, error in

            guard let samples = results as? [HKQuantitySample] else { return }

            let startDate = self.workoutSession?.startDate ?? Date()
            let endDate = self.workoutSession?.endDate ?? Date()
            let duration = endDate.timeIntervalSince(startDate)
            let totalKcalBurnedQuantity = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: self.kcalObserver.getActiveCaloriesBurned())

            let workout = HKWorkout(
                activityType: self.workoutSession!.activityType,
                start: startDate, end: endDate,
                duration: duration,
                totalEnergyBurned: totalKcalBurnedQuantity,
                totalDistance: nil,
                device: HKDevice.local(),
                metadata: [HKMetadataKeyIndoorWorkout: true])

            self.healthStore.save(workout) {
                success, error in
                guard success else {
                    fatalError("ERROR")
                }

                self.healthStore.add(samples, to: workout) {
                    success, error in
                    guard success else {
                        fatalError("ERROR")
                    }

                    print("Workout saved.")
                }
            }
        }

        healthStore.execute(query)
    }
    
    func startKcalQuery() {
        kcalObserver.start()
    }
    
    func startHearthRateQuery(from: Date, onUpdate: @escaping ([HKQuantitySample]) -> Void) {
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            QueryPredicate.date(startDate: from).value, QueryPredicate.device.value])
    
        let resultHandler: ResultHandler = {
            _, samples, _, _, error in
            
            guard let samples = samples as? [HKQuantitySample] else {
                // TODO: handle this case.
                return
            }
            
            onUpdate(samples)
        }
        
        let query = HKAnchoredObjectQuery(type: HKQuantityType.hearthRate, predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: resultHandler)
        query.updateHandler = resultHandler
        
        healthStore.execute(query)
    }
    
    func stopHearthRateQuery() {
        guard let query = hearthRateQuery else { return }
        healthStore.stop(query)
    }

    
    private init() {
        self.kcalObserver = KcalObserver(updateInterval: 20, healthStore: self.healthStore)
    }
    
    private let healthStore = HKHealthStore()
    private var hearthRateQuery: HKQuery?
    private var workoutSession: HKWorkoutSession?
    
    private var workoutConfiguration: HKWorkoutConfiguration {
        let config = HKWorkoutConfiguration()
        config.activityType = .traditionalStrengthTraining
        config.locationType = .indoor
        return config
    }
    
    private enum QueryPredicate {
        case date(startDate: Date)
        case device
        
        var value: NSPredicate {
            switch self {
            case .date(let date):
                return HKQuery.predicateForSamples(withStart: date, end: nil, options: .strictStartDate)
            case .device:
                return HKQuery.predicateForObjects(from: [HKDevice.local()])
            }
        }
    }
}

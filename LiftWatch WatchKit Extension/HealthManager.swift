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

    typealias ResultHandler = ((HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void)
    
    public static let shared = HealthManager()
    
    func isHearthRateAccessGranted() -> Bool {
        let status = healthStore.authorizationStatus(
            for: HKObjectType.quantityType(forIdentifier: .heartRate)!
        )
        
        return status == .sharingAuthorized
    }
    
    func start(session: HKWorkoutSession) {
        healthStore.start(session)
    }

    func end(session: HKWorkoutSession) {
        healthStore.end(session)
    }
    
    func saveWorkout() {
        
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
    
    private init() {}
    private let healthStore = HKHealthStore()
    private var hearthRateQuery: HKQuery?
    
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

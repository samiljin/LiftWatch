//
//  AccessRights.swift
//  LiftWatch
//
//  Created by Sami Iljin on 04/05/2018.
//  Copyright © 2018 Sami Iljin. All rights reserved.
//

import HealthKit

class AccessRights {
    
    static func request(completion: @escaping (Bool, Error?) -> Void) {
        HealthManager.shared.healthStore.requestAuthorization(
            toShare: typesNeededForWriting, read: typesNeededForReading, completion: completion)
    }
    
    static var isAllGiven: Bool {
        let allTypes = typesNeededForReading.union(typesNeededForWriting)
        let states = allTypes.map { HealthManager.shared.healthStore.authorizationStatus(for: $0) }
        let given = states.filter { $0 == .sharingAuthorized }
        
        return given.count == allTypes.count
    }
    
    private static let typesNeededForWriting = Set([
        HKObjectType.workoutType()
    ])
    
    private static let typesNeededForReading = Set([
        HKObjectType.workoutType(),
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
    ])
    
}

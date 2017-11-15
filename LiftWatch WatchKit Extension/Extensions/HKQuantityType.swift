//
//  HKQuantityType.swift
//  LiftWatch WatchKit Extension
//
//  Created by Sami Iljin on 14/11/2017.
//  Copyright © 2017 Sami Iljin. All rights reserved.
//

import Foundation
import HealthKit

extension HKQuantityType {
    static var hearthRate: HKQuantityType {
        return HKObjectType.quantityType(forIdentifier: .heartRate)!
    }
}

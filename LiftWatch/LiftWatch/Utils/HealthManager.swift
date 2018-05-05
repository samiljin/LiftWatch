//
//  HealthManager.swift
//  LiftWatch
//
//  Created by Sami Iljin on 04/05/2018.
//  Copyright © 2018 Sami Iljin. All rights reserved.
//

import HealthKit

class HealthManager {
    
    static let shared = HealthManager()
    let healthStore = HKHealthStore()
    
}

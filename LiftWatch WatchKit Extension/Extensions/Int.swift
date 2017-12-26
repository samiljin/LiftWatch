//
//  Int.swift
//  LiftWatch WatchKit Extension
//
//  Created by Sami Iljin on 19/11/2017.
//  Copyright © 2017 Sami Iljin. All rights reserved.
//

import Foundation

extension Int {
    
    typealias ElapsedTime = (Int, Int, Int)
    
    func secondsToElapsedTimeFormat() -> ElapsedTime {
        return (self / 3600, (self % 3600) / 60, (self % 3600) % 60)
    }
    
}

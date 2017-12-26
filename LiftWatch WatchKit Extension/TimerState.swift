//
//  TimerState.swift
//  LiftWatch WatchKit Extension
//
//  Created by Sami Iljin on 26/11/2017.
//  Copyright © 2017 Sami Iljin. All rights reserved.
//

import Foundation

enum TimerState {
    case initialized, running, paused, continued, reset
    
    var buttonTitle: String {
        switch self {
        case .initialized:
            return "Start"
        case .running:
            return "Pause"
        case .paused:
            return "Continue"
        case .continued:
            return "Pause"
        case .reset:
            return "Start"
        }
    }
}

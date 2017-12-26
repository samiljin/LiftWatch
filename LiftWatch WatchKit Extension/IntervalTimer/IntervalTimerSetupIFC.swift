//
//  SequenceTimerIFC.swift
//  LiftWatch
//
//  Created by Sami Iljin on 11/11/2017.
//  Copyright © 2017 Sami Iljin. All rights reserved.
//

import WatchKit
import Foundation

typealias IntervalTimes = (workoutTime: Int, restTime: Int)

class IntervalTimerSetupIFC: WKInterfaceController {
    @IBOutlet var workoutTimePicker: WKInterfacePicker!
    @IBOutlet var restTimePicker: WKInterfacePicker!
    @IBOutlet var button: WKInterfaceButton!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        removeTitle()
        
        buildItems()
        
        workoutTimePicker.setItems(items)
        restTimePicker.setItems(items)
        
        workoutTimePicker.setSelectedItemIndex(2)
        restTimePicker.setSelectedItemIndex(0)
    }
    
    @IBAction func workoutTimerValueChanged(_ value: Int) {
        selectedWorkoutTimeInSeconds = Int(items[value].title!)!
    }
    
    @IBAction func restTimerValueChanged(_ value: Int) {
        selectedRestTimeInSeconds = Int(items[value].title!)!
    }
    
    private func buildItems() {
        for index in 1...18 {
            let title = index * 10
            let item = WKPickerItem()
            item.title = "\(title)"
            
            self.items.append(item)
        }
    }
    
    private var items: [WKPickerItem] = []

    private var selectedWorkoutTimeInSeconds: Int = 30
    private var selectedRestTimeInSeconds: Int = 10
    
    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        switch segueIdentifier {
        case "StartIntervarTimerSeguence":
            return IntervalTimes(workoutTime: selectedWorkoutTimeInSeconds, restTime: selectedRestTimeInSeconds)
        default:
            fatalError()
        }
    }
    
}

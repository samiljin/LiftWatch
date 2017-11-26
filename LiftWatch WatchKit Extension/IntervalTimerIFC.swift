//
//  SequenceTimerIFC.swift
//  LiftWatch
//
//  Created by Sami Iljin on 11/11/2017.
//  Copyright © 2017 Sami Iljin. All rights reserved.
//

import WatchKit
import Foundation


class IntervalTimerIFC: WKInterfaceController {
    @IBOutlet var workoutTimePicker: WKInterfacePicker!
    @IBOutlet var restTimePicker: WKInterfacePicker!
    @IBOutlet var workoutTimeLabel: WKInterfaceLabel!
    @IBOutlet var restTimeLabel: WKInterfaceLabel!
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

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func buttonClicked() {
        intervalTimerRunning = !intervalTimerRunning
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
    
    private func showTimeLabels() {
        workoutTimeLabel.setText("\(selectedWorkoutTimeInSeconds)")
        restTimeLabel.setText("\(selectedRestTimeInSeconds)")
        
        workoutTimePicker.setHidden(true)
        restTimePicker.setHidden(true)
        
        workoutTimeLabel.setHidden(false)
        restTimeLabel.setHidden(false)
    }
    
    private func startWorkoutTimer() {
        workoutTimer?.invalidate()
        
        workoutTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
            [unowned self] timer in
            self.elapsedWorkoutTimeInSeconds += 1
            
            if self.selectedWorkoutTimeInSeconds == self.elapsedWorkoutTimeInSeconds {
                timer.invalidate()
                self.elapsedWorkoutTimeInSeconds = 0
                self.startRestTimer()
            }
        }
    }
    
    private func startRestTimer() {
        restTimer?.invalidate()
        
        restTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
            [unowned self] timer in
            self.elapsedRestTimeInReconds += 1
            
            if self.selectedRestTimeInSeconds == self.elapsedRestTimeInReconds {
                timer.invalidate()
                self.elapsedRestTimeInReconds = 0
                self.startWorkoutTimer()
            }
        }
    }
    
    private func pauseTimers() {
        workoutTimer?.invalidate()
        restTimer?.invalidate()
    }
    
    private var workoutTimer: Timer?
    private var restTimer: Timer?
    
    private var items: [WKPickerItem] = []

    private var selectedWorkoutTimeInSeconds: Int = 30
    private var selectedRestTimeInSeconds: Int = 10
    
    private var elapsedRestTimeInReconds: Int = 0 {
        didSet {
            let timeLeft = selectedRestTimeInSeconds - elapsedRestTimeInReconds
            restTimeLabel.setText("\(timeLeft)")
        }
    }
    
    private var elapsedWorkoutTimeInSeconds: Int = 0 {
        didSet {
            let timeLeft = selectedWorkoutTimeInSeconds - elapsedWorkoutTimeInSeconds
            workoutTimeLabel.setText("\(timeLeft)")
        }
    }
    
    private var intervalTimerRunning = false {
        didSet {
            if intervalTimerRunning {
                button.setTitle("Pause")
                showTimeLabels()
                startWorkoutTimer()
            } else {
                button.setTitle("Start")
            }
        }
    }
}

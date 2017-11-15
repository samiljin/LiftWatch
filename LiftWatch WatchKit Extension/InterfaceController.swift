//
//  InterfaceController.swift
//  LiftWatch WatchKit Extension
//
//  Created by Sami Iljin on 08/11/2017.
//  Copyright © 2017 Sami Iljin. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if HealthManager.shared.isHearthRateAccessGranted() {
            
        } else {
            // TODO: Beg for permission.
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}

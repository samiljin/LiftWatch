//
//  ViewController.swift
//  LiftWatch
//
//  Created by Sami Iljin on 04/05/2018.
//  Copyright © 2018 Sami Iljin. All rights reserved.
//

import UIKit

class AccessRightsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if AccessRights.isAllGiven { return }

        AccessRights.request {
            success, error in
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


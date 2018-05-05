//
//  ViewController.swift
//  LiftWatch
//
//  Created by Sami Iljin on 04/05/2018.
//  Copyright © 2018 Sami Iljin. All rights reserved.
//

import UIKit
import SnapKit
import HealthKit

class AccessRightsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        askAccessRightsButton.tapped = {
            AccessRights.request {
                [unowned self] success, error in
                guard let error = error else {
                    self.accessRightsAsked(with: success)
                    return
                }

                self.accessRightsAsked(with: error)
            }
        }
        
        view.addSubview(askAccessRightsButton)
        askAccessRightsButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(100)
            $0.width.equalToSuperview().offset(-20)
        }
    }
    
    private func accessRightsAsked(with success: Bool) {
        print(success)
        // TOOD: Move to next VC
    }
    
    private func accessRightsAsked(with error: Error) {
        print(error)
        // TODO:
    }

    private lazy var askAccessRightsButton: LWButton = {
        let button = LWButton()
        button.backgroundColor = UIColor.yellow
        button.setTitle("Yes, i'd like to give you the permissions <3", for: .normal)
        button.tintColor = UIColor.blue
        return button
    }()

}


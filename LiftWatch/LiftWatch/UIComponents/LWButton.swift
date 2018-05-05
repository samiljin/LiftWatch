//
//  LWButton.swift
//  LiftWatch
//
//  Created by Sami Iljin on 05/05/2018.
//  Copyright © 2018 Sami Iljin. All rights reserved.
//

import UIKit

class LWButton : UIButton {
    var tapped: (() -> ())?
    
    init() {
        super.init(frame: CGRect.zero)
        addTarget(self, action: #selector(onTap), for: .touchDown)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onTap() {
        tapped?()
    }
}

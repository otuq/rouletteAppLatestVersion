//
//  Start.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/09.
//

import UIKit

class RouletteStart {
    private var input: InterfaceInput!
    
    init(input: InterfaceInput) {
        self.input = input
    }
    func start() {
        input.lbs.forEach { label in
            label.isHidden = true
        }
        input.bt.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.input.vw.startRotateAnimation()
            self.input.vw.rouletteSoundSetting()
        }
    }
}

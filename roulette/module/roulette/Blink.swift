//
//  Blink.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/09.
//

import UIKit

class Blink {
    private var input: InterfaceInput!

    init(input: InterfaceInput) {
        self.input = input
    }
    func blink() {
        input.lbs.forEach { label in
            UIView.transition(with: label, duration: 1.0, options: [.transitionCrossDissolve, .autoreverse, .repeat], animations: {
                label.layer.opacity = 0
            }, completion: { _ in
                label.layer.opacity = 1
            })
        }
    }
}

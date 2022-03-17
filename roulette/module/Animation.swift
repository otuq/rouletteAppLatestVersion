//
//  Animation.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/17.
//

import UIKit

import UIKit

class Animation{
    static let shared = Animation()
    func blink(object: AnyObject) {
        guard let object = object as? UIView else { return print("点滅できません") }
        UIView.transition(with: object, duration: 1.0, options: [.transitionCrossDissolve, .autoreverse, .repeat], animations: {
            object.layer.opacity = 0
        }, completion: { _ in
            object.layer.opacity = 1
        })
    }
}


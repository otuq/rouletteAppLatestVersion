//
//  StartLabel.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/17.
//

import UIKit

struct StartLabel {
    static let shared = StartLabel()
    
    func create() -> UILabel {
        let label = UILabel()
        label.bounds.size = CGSize(width: 200, height: 20)
        label.textAlignment = .center
        label.baselineAdjustment = .alignCenters
        label.text = "T A P"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(r: 153, g: 153, b: 153)
        label.fontSizeRecalcForEachDevice()
        Animation.shared.blink(object: label)
        return label
    }
}

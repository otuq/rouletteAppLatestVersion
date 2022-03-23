//
//  Colors.swift
//  roulette
//
//  Created by USER on 2021/09/16.
//

import UIKit

extension UIColor {
    // MARK: Properties
    var r: Int {
        Int(self.cgColor.components![0] * 255)
    }
    var g: Int {
        Int(self.cgColor.components![1] * 255)
    }
    var b: Int {
        Int(self.cgColor.components![2] * 255)
    }
    var a: Int {
        Int(self.cgColor.components![3] * 255)
    }

    // MARK: Init
    // rgb値を分割して取得
    convenience init(r: Int, g: Int, b: Int, a: CGFloat = 1.0) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }

    // MARK: Methods
    static func hsvToRgb(h: Float, s: Float, v: Float) -> UIColor {
        var r = h
        var g = s
        var b = v

        let max = max(s, v)
        let min = max - ((s / 255) * max)

        // H=300~360
        if h > 300 {
            r = max
            g = min
            b = ((360 - h) / 60) * (max - min) + min
        }
        // H=240~300
        else if h > 240 {
            r = ((h - 240) / 60) * (max - min) + min
            g = min
            b = max
        }
        // H=180~240
        else if h > 180 {
            r = min
            g = ((240 - h) / 60) * (max - min) + min
            b = max
        }
        // H=120~180
        else if h > 120 {
            r = min
            g = max
            b = ((h - 120) / 60) * (max - min) + min
        }
        // H=60~120
        else if h > 60 {
            r = ((120 - h) / 60) * (max - min) + min
            g = max
            b = min
        }
        // H=0~60
        else if h >= 0 {
            r = max
            g = (h / 60) * (max - min) + min
            b = min
        }
        return UIColor(r: Int(r), g: Int(g), b: Int(b))
    }
    static var lightestGray: UIColor {
        return UIColor(r: 223, g: 223, b: 223)
    }
    static func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return dark
            } else {
                return light
            }
        }
    }
}

//
//  Model.swift
//  roulette
//
//  Created by USER on 2021/06/30.
//

import RealmSwift
import UIKit

enum Speed: String {
    case slow, normal, fast
}
// MARK: - RouletteData
class RouletteData: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var dataId: String = ""
    @objc dynamic var colorIndex: Int = 0
    @objc dynamic var randomFlag = false
    @objc dynamic var date = Date()
    @objc dynamic var lastDate = Date()
    var list = List<RouletteGraphData>()
    // 初期色cyan colorselectVCで色を選択したらここに一時保存してnewDataVCの方でデータ保存する。
    var temporarys = [RouletteGraphTemporary]()
    var index: Int = 0
}
// MARK: - RouletteGraphData
class RouletteGraphData: Object {
    @objc dynamic var text: String = ""
    @objc dynamic var r: Int = 255
    @objc dynamic var g: Int = 255
    @objc dynamic var b: Int = 255
    @objc dynamic var ratio: Float = 1
}
// MARK: - RouletteGraphTemporary
class RouletteGraphTemporary {
    var textTemporary: String = ""
    var rgbTemporary = ["r": 255, "g": 255, "b": 255] // 初期値white
    var ratioTemporary: Float = 1
}
// MARK: - AppSettingForm
extension RouletteData {
    var formValues: [String: Any] {
        let userDefaults = UserDefaults.standard
        let values = userDefaults.object(forKey: "form")as? [String: Any] ?? [:]
        return values
    }
    var speed: CGFloat {
        let speedString = formValues["speed"] as? String ?? "normal"
        if let speed = Speed(rawValue: speedString) {
            switch speed {
            case .slow:     return 10.0
            case .normal:   return 20.0
            case .fast:     return 30.0
            }
        }
        return 0.0
    }
    var textColor: UIColor {
        let rgb = formValues["colorPicker"] as? [Int] ?? [0, 0, 0]
        let color = UIColor(r: rgb[0], g: rgb[1], b: rgb[2])
        return color
    }
    var sound: String {
        formValues["sound"] as? String ?? "timpani"
    }
    var effect: String {
        formValues["effect"] as? String ?? "symbal"
    }
}

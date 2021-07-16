//
//  Model.swift
//  roulette
//
//  Created by USER on 2021/06/30.
//

import UIKit
import RealmSwift

enum Speed: String {
    case slow, normal, fast
}

class RouletteData: Object {
    @objc dynamic var title: String = ""
    var list = List<RouletteGraphData>()
    //初期色cyan colorselectVCで色を選択したらここに一時保存してnewDataVCの方でデータ保存する。
    var temporarys = [RouletteGraphTemporary]()
    var index: Int = 0
    
    var formValues: [String: Any] {
        let userDefaults = UserDefaults.standard
        let values = userDefaults.object(forKey: "form")as? [String: Any] ?? [:]
        return values
    }
    var speed: CGFloat {
        let speedString = formValues["speed"] as? String ?? ""
        if let speed = Speed.init(rawValue: speedString){
            switch speed {
            case .slow:     return 10.0
            case .normal:   return 20.0
            case .fast:     return 30.0
            }
        }
        return 0.0
    }
    var textColor: UIColor {
        let rgb = formValues["colorPicker"] as? [Int] ?? [0,255,255]
        let color = UIColor.init(r: rgb[0], g: rgb[1], b: rgb[2])
        return color
    }
}
class RouletteGraphData: Object {
    @objc dynamic var text: String = ""
    @objc dynamic var r: Int = 0
    @objc dynamic var g: Int = 255
    @objc dynamic var b: Int = 255
}
class RouletteGraphTemporary {
    var textTemporary: String = ""
    var rgbTemporary = ["r": 0,"g": 255, "b": 255] //初期値cyan
}

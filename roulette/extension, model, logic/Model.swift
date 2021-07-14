//
//  Model.swift
//  roulette
//
//  Created by USER on 2021/06/30.
//

import UIKit
import RealmSwift

class RouletteData: Object {
    @objc dynamic var title: String = ""
    var list = List<RouletteGraphData>()
    var index: Int = 0
    //初期色cyan colorselectVCで色を選択したらここに一時保存してnewDataVCの方でデータ保存する。
    var temporarys = [RouletteGraphTemporary]()
    //    override class func primaryKey() -> String? {
    //        let uniqId = NSUUID.init().uuidString
    //        return uniqId
    //    }
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

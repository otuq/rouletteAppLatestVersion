//
//  Model.swift
//  roulette
//
//  Created by USER on 2021/06/30.
//

import UIKit
import RealmSwift

class RouletteData: Object {
    dynamic var title: String = ""
    dynamic var rouletteData: [RouletteGraphData] = []
    
//    init(dic: [String: Any]) {
//        text = dic["text"]as? String ?? ""
//        color = dic["color"]as? UIColor ?? .white
//    }
}
class RouletteGraphData {
    dynamic var text: String = ""
    dynamic var color: UIColor = .cyan
}

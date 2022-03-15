//
//  RouletteVCPresenter.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/08.
//

import Foundation
import RealmSwift

protocol RouletteInput {
    var dataSetPresenter: (dataSet: RouletteData, list: List<RouletteGraphData>) { get }
}
class RoulettePresenter {
    var rouletteDataSet: (dataSet: RouletteData, list: List<RouletteGraphData>)!
    // このプロパティは循環参照を引き起こす可能性があってルーレットが終わった後にメモリが解放されないので弱参照にする
    private weak var output: RouletteOutput!
    private var rouletteView: RouletteView!
    
    init(with output: RouletteOutput) {
        self.output = output
    }
    func viewDidload() {
        rouletteCreate()
    }
    private func rouletteCreate() {
        rouletteView = RouletteView(input: self)
    }
    func tapStart() {
        output.tapStart { labels in
            labels.forEach { $0.isHidden = true }
        }
        //view range speed textColor(rgb) rouletteVw Dataset
        _ = RouletteAnimation(input: rouletteView)
    }
    func tapQuit() {
        output.tapQuit { vc in
            AlertAppear.shared.appear(input: vc)
        }
    }
}
extension RoulettePresenter: RouletteInput {
    var dataSetPresenter: (dataSet: RouletteData, list: List<RouletteGraphData>) {
        rouletteDataSet
    }
}

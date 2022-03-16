//
//  RouletteVCPresenter.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/08.
//

import Foundation

protocol RouletteInput {
    func loadRouletteView(dataSet: RouletteData) -> RouletteView
    func rouletteStart()
}

class RoulettePresenter {
    // このプロパティは循環参照を引き起こす可能性があってルーレットが終わった後にメモリが解放されないので弱参照にする
    private weak var output: RouletteOutput!
    private var rouletteView: RouletteView!
    
    init(with output: RouletteOutput) {
        self.output = output
    }
}
extension RoulettePresenter: RouletteInput {
    func loadRouletteView(dataSet: RouletteData) -> RouletteView {
        rouletteView = RouletteView(output: output.dataPresent)
        return rouletteView
    }
    func rouletteStart() {
        output.hiddenLabel()
        _ = RouletteAnimation(input: output.dataPresent, view: rouletteView)
    }
}


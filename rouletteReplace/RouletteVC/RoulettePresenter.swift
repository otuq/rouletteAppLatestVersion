//
//  RouletteVCPresenter.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/08.
//

import Foundation

protocol RouletteInput {
    func viewDidLoad()
    func rouletteStart()
}
class RoulettePresenter: ShareProperty {
    // このプロパティは循環参照を引き起こす可能性があってルーレットが終わった後にメモリが解放されないので弱参照にする
    private weak var output: RouletteOutput!
    private var rouletteView: RouletteView!
    private var dataSet: DataSet?

    init(with output: RouletteOutput) {
        self.output = output
        
        guard let lastDataSet = LoadData.shared.lastSetData() else { return }
        self.dataSet = (lastDataSet, lastDataSet.list)
        if let dataSet = dataSet {
            rouletteView = RouletteView(dataSet: dataSet)
        }
    }
}
extension RoulettePresenter: RouletteInput {
    func viewDidLoad() {
        guard dataSet != nil else { return }
        output.addModule(addView: rouletteView)
    }
    func rouletteStart() {
        output.hiddenLabel()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.rouletteView.startRotateAnimation()
            self.rouletteView.rouletteSoundSetting()
        }
    }
}

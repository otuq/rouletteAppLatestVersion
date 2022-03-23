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
class RoulettePresenter {
    // このプロパティは循環参照を引き起こす可能性があってルーレットが終わった後にメモリが解放されないので弱参照にする
    private weak var output: RouletteOutput!
    private var rouletteView: RouletteView!
    
    init(with output: RouletteOutput) {
        self.output = output
        rouletteView = RouletteView(dataSet: output.dataPresent)
    }
}
extension RoulettePresenter: RouletteInput {
    internal func viewDidLoad() {
        createRouletteView()
        createRouletteModule()
    }
    internal func rouletteStart() {
        output.hiddenLabel()
        RouletteAnimation(input: output.dataPresent, view: rouletteView).startRotateAnimation()
        RouletteSound.shared.rouletteSoundSetting(soundName: output.dataPresent.dataSet.sound)
    }
    private func createRouletteView() {
        output.vc.view.addSubview(rouletteView)
    }
    private func createRouletteModule() {
        let module = RouletteModule(output: output)
        module.addPointer()
        module.addFrameCircle()
        module.addCenterCircle()
    }
}

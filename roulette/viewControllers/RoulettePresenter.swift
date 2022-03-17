//
//  RouletteVCPresenter.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/08.
//

import Foundation

protocol RouletteInput {
    func createRouletteView()
    func createRouletteModule()
    func rouletteStart()
}
class RoulettePresenter {
    // このプロパティは循環参照を引き起こす可能性があってルーレットが終わった後にメモリが解放されないので弱参照にする
    private weak var output: RouletteOutput!
    private var rouletteView: RouletteView!
    
    init(with output: RouletteOutput) {
        self.output = output
        createRouletteView()
        createRouletteModule()
    }
}
extension RoulettePresenter: RouletteInput {
    internal func createRouletteView() {
        rouletteView = RouletteView(output: output.dataPresent)
        output.vc.view.addSubview(rouletteView)
    }
    internal func createRouletteModule() {
        let module = RouletteModule(output: output)
        let pointerImageView = module.pointerImageView()
        let centerCircleLabel = module.centerCircleLabel()
        let frameCircleView = module.frameCircleView()
        [pointerImageView, centerCircleLabel, frameCircleView].forEach { add in
            output.vc.view.addSubview(add)
        }
        output.vc.view.bringSubviewToFront(pointerImageView)
    }
    internal func rouletteStart() {
        output.hiddenLabel()
        RouletteAnimation(input: output.dataPresent, view: rouletteView).startRotateAnimation()
        RouletteSound.shared.rouletteSoundSetting(soundName: output.dataPresent.dataSet.sound)
    }
}


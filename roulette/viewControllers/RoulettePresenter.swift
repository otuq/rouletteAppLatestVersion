//
//  RouletteVCPresenter.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/08.
//

import Foundation

class RoulettePresenter {
    // このプロパティは循環参照を引き起こす可能性があってルーレットが終わった後にメモリが解放されないので弱参照にする
    private weak var input: InterfaceInput!
    
    init(with input: InterfaceInput) {
        self.input = input
    }
    func viewDidload() {
        settingUI()
        blinkAnimation()
        rouletteModule()
    }
    func alertAppear() {
        AlertAppear(input: input).appear()
    }
    func rouletteStart() {
        RouletteStart(input: input).start()
    }
    private func settingUI() {
        input.bt.imageSet()
        input.bt.fontSizeRecalcForEachDevice()
        input.lbs.forEach{ $0.fontSizeRecalcForEachDevice() }
    }
    private func blinkAnimation() {
        Blink(input: input).blink()
    }
    private func rouletteModule() {
        let module = RouletteModule(input: input)
        module.addRoulette()
        module.addPointer()
        module.addCenterCircle()
        module.addFrameCircle()
    }
    deinit {
        print("deinit: presenter")
    }
}

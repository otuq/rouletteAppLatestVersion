//
//  HomePresenter.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/17.
//

import Foundation

protocol HomeInput: AnyObject {
    func createStartLabel()
    func rouletteVCTransition()
    func setVCTranstion()
    func newVCTranstion()
    func editVCTransition()
    func appSettingVCTransition()
    func shareVCTransition()
}
class HomePresenter {
    private var output: HomeOutput!
    private var transition: Transition!
    
    init(with output: HomeOutput) {
        self.output = output
    }
}
extension HomePresenter: HomeInput {
    func createStartLabel() {
        let label = StartLabel.shared.create()
        output.addStartLabel(label: label)
    }
    func rouletteVCTransition() {
        if let dataSet = output.dataPresent {
            let vc = R.storyboard.roulette.rouletteViewController()
            vc?.rouletteDataSet = (dataSet, dataSet.list)
            Transition.shared.modalPresent(vc: vc, presentation: .overFullScreen, transition: .crossDissolve)
        }
    }
    func setVCTranstion() {
        let vc = R.storyboard.setData.setDataViewController()
        output.setDataSelectedTrue()
        Transition.shared.modalPresent(vc: vc, presentation: .overFullScreen)
    }
    func newVCTranstion() {
        let vc = R.storyboard.newData.newDataViewController()
        // newButtonの選択状態で新規か更新の分岐をする
        output.newDataSelectedTrue()
        Transition.shared.modalPresent(vc: vc, presentation: .overFullScreen)
    }
    func editVCTransition() {
        if let dataSet = output.dataPresent {
            let vc = R.storyboard.newData.newDataViewController()
            // listに保存されたデータをtemporaryに代入しないとcancelしても前のセルが上書きされる。
            dataSet.temporarys.removeAll()
            dataSet.list.forEach { list in
                let temporary = RouletteGraphTemporary()
                temporary.textTemporary = list.text
                temporary.rgbTemporary["r"] = list.r
                temporary.rgbTemporary["g"] = list.g
                temporary.rgbTemporary["b"] = list.b
                temporary.ratioTemporary = list.ratio
                dataSet.temporarys.append(temporary)
            }
            vc?.dataSet = dataSet
            Transition.shared.modalPresent(vc: vc, presentation: .overFullScreen)
        }
    }
    func appSettingVCTransition() {
        let vc = R.storyboard.appSetting.appSettingViewController()
        Transition.shared.modalPresent(vc: vc, presentation: .overFullScreen)
    }
    func shareVCTransition() {
        let vc = ShareViewController.shared.create()
        Transition.shared.modalPresent(vc: vc)
    }
}

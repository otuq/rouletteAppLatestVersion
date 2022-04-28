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
    func newDataVCTransition()
    func setVCTranstion()
    func editVCTransition()
    func appSettingVCTransition()
    func shareVCTransition()
}
class HomePresenter {
    private weak var output: HomeOutput!
    private var dataSet: RouletteData?
    
    init(with output: HomeOutput) {
        self.output = output
        self.dataSet = FetchData.shared.latestData()
    }
}
extension HomePresenter: HomeInput {
    func createStartLabel() {
        guard let dataSet = dataSet else { return }
        output.createStartLabel(dataSet: dataSet)
    }
    func rouletteVCTransition() {
        guard dataSet != nil else { return }
        output.rouletteVCTransition()
    }
    func newDataVCTransition() {
        output.newDataVCTransition()
    }
    func setVCTranstion() {
        guard dataSet != nil else { return }
        output.setDataVCTranstion()
    }
    func editVCTransition() {
        guard dataSet != nil else { return }
        output.editDataVCTransition()
    }
    func appSettingVCTransition() {
        output.appSettingVCTransition()
    }
    func shareVCTransition() {
        output.shareVCTransition()
    }
}

//
//  SetDataPresenter.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/22.
//

import Foundation

protocol SetDataInput {
    var numberOfRows: Int { get }
    func newDataVCTransition(indexPath: IndexPath)
    func getData(indexPath: IndexPath) -> RouletteData
    func deleteData(indexPath: IndexPath)
    func cancelBarBTN()
}
class SetDataPresenter {
    private var output: SetDataOutput!
    private var load: LoadData!
    init(with output: SetDataOutput) {
        self.output = output
        self.load = LoadData()
    }
}
extension SetDataPresenter: SetDataInput {
    var numberOfRows: Int { load.resultsData.count }
    func newDataVCTransition(indexPath: IndexPath) {
        guard let vc = R.storyboard.newData.newDataViewController() else { return }
        // 選択したグラフデータのインデックスとrgb情報を
        let dataSet = load.resultsData[indexPath.row]
        dataSet.list.forEach { list in
            let temporary = RouletteGraphTemporary()
            temporary.textTemporary = list.text
            temporary.rgbTemporary["r"] = list.r
            temporary.rgbTemporary["g"] = list.g
            temporary.rgbTemporary["b"] = list.b
            temporary.ratioTemporary = list.ratio
            dataSet.temporarys.append(temporary)
        }
        vc.dataSet = dataSet
        output.transitionNewDataVC(vc: vc)
    }
    func getData(indexPath: IndexPath) -> RouletteData {
        let sortData = load.sortData(key: "date")
        return sortData[indexPath.row]
    }
    func deleteData(indexPath: IndexPath) {
        // データベースからルーレット情報を削除する。
        guard let rootVC = output.rootVC else { return }
        // 現在セットしているデータは消せない
        if rootVC.dataSet?.dataId == load.resultsData[indexPath.row].dataId {
            output.alertAppear()
        } else {
            load.deleteData(indexPath: indexPath)
        }
    }
}

//
//  SetDataPresenter.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/22.
//

import Foundation

protocol SetDataInput {
    var numberOfRows: Int { get }
    func newDataVCTransition(indexPath: IndexPath, completion: (NewDataViewController) -> Void)
    func getDatas(indexPath: IndexPath) -> RouletteData?
    func deleteData(indexPath: IndexPath, execute: () -> Void, completion: () -> Void)
}
class SetDataPresenter {
    private var load: LoadData!
    init() { self.load = LoadData() }
}
extension SetDataPresenter: SetDataInput {
    var numberOfRows: Int { load.dataCount }
    func newDataVCTransition(indexPath: IndexPath, completion: (NewDataViewController) -> Void) {
        guard let vc = R.storyboard.newData.newDataViewController(),
              let sortDatas = load.sortData() else { return }
        let dataSet = sortDatas[indexPath.row]
        dataSet.list.forEach { list in
            let temporary = temporary(list: list)
            dataSet.temporarys.append(temporary)
        }
        completion(vc)
    }
    func getDatas(indexPath: IndexPath) -> RouletteData? {
        guard let sortDatas = load.sortData() else { return nil }
        let dataSet = sortDatas[indexPath.row]
        dataSet.list.forEach { list in
            let temporary = temporary(list: list)
            dataSet.temporarys.append(temporary)
        }
        return dataSet
    }
    func deleteData(indexPath: IndexPath, execute: () -> Void, completion: () -> Void) {
        let currentData = load.lastSetData()
        let selectData = load.sortData()
        if currentData?.dataId == selectData?[indexPath.row].dataId {
            execute()
        } else {
            load.deleteData(indexPath: indexPath)
            completion()
        }
    }
    private func temporary(list: RouletteGraphData) -> RouletteGraphTemporary {
        // 選択したグラフデータのrgbと比率
        let temporary = RouletteGraphTemporary()
        temporary.textTemporary = list.text
        temporary.rgbTemporary["r"] = list.r
        temporary.rgbTemporary["g"] = list.g
        temporary.rgbTemporary["b"] = list.b
        temporary.ratioTemporary = list.ratio
        return temporary
    }
}

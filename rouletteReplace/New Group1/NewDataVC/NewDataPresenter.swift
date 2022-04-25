//
//  NewDataPresenter.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/25.
//

import Foundation

protocol NewDataInput {
    var numberOfRows: Int { get }
    var randomSwitchFlag: Bool { get }
    func getGraphTemporary(index: Int) -> RouletteGraphTemporary
    func setContents()
    func saveContents()
    func moveRow(_ sourceIndexPath: IndexPath, _ destinationIndexPath: IndexPath)
    func deleteRow(_ indexPath: IndexPath)
    func addDataTemporary()
}
class NewDataPresenter {
    private weak var output: NewDataOutput!
    private var dataSet = RouletteData()
    
    init(with output: NewDataOutput, selected: Bool) {
        self.output = output
        // 新規と編集の分岐
        if !(selected), let dataSet = LoadData.shared.lastSetData() {
            self.dataSet = dataSet
            dataSet.list.forEach { graphData in
                let temporary = RouletteGraphTemporary()
                temporary.textTemporary = graphData.text
                temporary.ratioTemporary = graphData.ratio
                temporary.rgbTemporary["r"] = graphData.r
                temporary.rgbTemporary["g"] = graphData.g
                temporary.rgbTemporary["b"] = graphData.b
                dataSet.temporarys.append(temporary)
            }
        }
    }
}
extension NewDataPresenter: NewDataInput {
    var numberOfRows: Int { dataSet.temporarys.count }
    var randomSwitchFlag: Bool { dataSet.randomFlag }
    func getGraphTemporary(index: Int) -> RouletteGraphTemporary {
        return dataSet.temporarys[index]
    }
    func setContents() {
        output.setContents(dataSet: dataSet)
    }
    func saveContents() {
        output.saveContents(dataSet: dataSet)
    }
    func moveRow(_ sourceIndexPath: IndexPath, _ destinationIndexPath: IndexPath) {
        let data = dataSet.temporarys[sourceIndexPath.row]
        dataSet.temporarys.remove(at: sourceIndexPath.row)
        dataSet.temporarys.insert(data, at: destinationIndexPath.row)
    }
    func deleteRow(_ indexPath: IndexPath) {
        dataSet.temporarys.remove(at: indexPath.row)
    }
    func addDataTemporary() {
        let row = output.addRow()
        dataSet.temporarys.insert(row, at: 0)
    }
}

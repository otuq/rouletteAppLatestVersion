//
//  SaveRoulette.swift
//  roulette
//
//  Created by USER on 2022/02/21.
//

import RealmSwift
import UIKit

struct SaveData {
    // MARK: Properties
    private var realm = try! Realm()
    private var vc: UIViewController!
    private var dataSet: RouletteData!
    
    init(with vc: UIViewController, dataSet: RouletteData) {
        self.vc = vc
        self.dataSet = dataSet
    }
    // MARK: Methods
    // データの保存
    func saveRouletteData(title: String, flag: Bool, colorIndex: Int) {
        guard let nav = vc.presentingViewController as? UINavigationController,
              let homeVC = nav.topViewController as? HomeViewController else { return print("nil") }
        if dataSet.temporarys.isEmpty { return print("temporary nil") }
        homeVC.view.endEditing(true)
        // 新規データの作成
        print(homeVC.newDataButton.isSelected)
        if homeVC.newDataButton.isSelected {
            newData()
            updateData(title, flag, colorIndex)
            homeVC.addStartLabel()
            vc.dismiss(animated: true)
            print("データを新規作成しました。")
            // データセットの更新
        } else if homeVC.setDataButton.isSelected {
            let message = "データを保存してセットしますか？"
            let titleA = "編集を続ける", titleB = "保存してセット"
            let alertVC = UIAlertController(title: .none, message: message, preferredStyle: .actionSheet)
            alertVC.selectJob(cancel: titleA, execute: titleB) {
                self.updateData(title, flag, colorIndex)
                homeVC.addStartLabel()
                vc.dismiss(animated: true)
                print("データセットからデータを更新しました。")
            }
            vc.present(alertVC, animated: true, completion: nil)
            // homeVCにセットしてあるデータの更新
        } else {
            let message = "データを上書きしますか？"
            let titleA = "編集を続ける", titleB = "上書きをする"
            let alertVC = UIAlertController(title: .none, message: message, preferredStyle: .actionSheet)
            alertVC.selectJob(cancel: titleA, execute: titleB) {
                self.updateData(title, flag, colorIndex)
                homeVC.addStartLabel()
                vc.dismiss(animated: true)
                print("編集からデータを更新しました。")
            }
            vc.present(alertVC, animated: true, completion: nil)
        }
    }
    private func newData() {
        try! realm.write({
            // データにIDを付ける。現在セット中のデータを削除できないようにするため。
            dataSet.dataId = NSUUID().uuidString
            dataSet.date = Date()
            realm.add(dataSet)
        })
    }
    // データベースへの書き込み
    private func updateData(_ title: String, _ flag: Bool, _ colorIndex: Int ) {
        // titleのデータの保存、更新
        try! realm.write({
            dataSet.title = title
            dataSet.randomFlag = flag
            dataSet.colorIndex = colorIndex
            dataSet.lastDate = Date()
            dataSet.list.removeAll()
        })
        // cellの情報のデータの保存、更新
        dataSet.temporarys.enumerated().forEach { index, temporary in
            try! realm.write({
                dataSet.list.insert(RouletteGraphData(), at: index)
                let list = dataSet.list[index]
                list.text = temporary.textTemporary
                list.r = temporary.rgbTemporary["r"]!
                list.g = temporary.rgbTemporary["g"]!
                list.b = temporary.rgbTemporary["b"]!
                list.ratio = temporary.ratioTemporary
            })
        }
    }
}

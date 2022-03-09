//
//  SaveRoulette.swift
//  roulette
//
//  Created by USER on 2022/02/21.
//

import RealmSwift
import UIKit

struct Save {
    // MARK: Properties
    private let referenceVC: NewDataViewController
    private let dataSet: RouletteData
    private var realm = try! Realm()

    // MARK: Init
    init(_ referenceVC: NewDataViewController, _ dataSet: RouletteData) {
        self.referenceVC = referenceVC
        self.dataSet = dataSet
    }

    // MARK: Methods
    // データの保存
    func saveRouletteData( title: String, flag: Bool, colorIndex: Int ) {
        guard let nav = referenceVC.presentingViewController as? UINavigationController,
              let homeVC = nav.topViewController as? HomeViewController,
              let view = referenceVC.view else { return }
        if dataSet.temporarys.isEmpty { return }
        view.endEditing(true)
        // 新規データの作成
        if homeVC.newDataButton.isSelected {
            realmWrite(title, flag, colorIndex)
            try! realm.write({
                // データにIDを付ける。現在セット中のデータを削除できないようにするため。
                dataSet.dataId = NSUUID().uuidString
                dataSet.date = Date()
                realm.add(dataSet)
            })
            self.setAndDismiss(homeVC)
            print("データを新規作成しました。")
            // データセットの更新
        } else if homeVC.setDataButton.isSelected {
            let alertVC = UIAlertController(title: .none, message: "データを保存してセットしますか？", preferredStyle: .actionSheet)
            let titleA = "編集を続ける", titleB = "保存してセット"
            alertVC.selectTwoChoice(titleA: titleA, titleB: titleB) {
                try! self.realm.write({
                    self.dataSet.list.removeAll()
                })
                self.realmWrite(title, flag, colorIndex)
                self.setAndDismiss(homeVC)
                print("データを更新しました。")
            }
            referenceVC.present(alertVC, animated: true, completion: nil)
            // homeVCにセットしてあるデータの更新
        } else {
            let alertVC = UIAlertController(title: .none, message: "データを上書きしますか？", preferredStyle: .actionSheet)
            let titleA = "編集を続ける", titleB = "上書きをする"
            alertVC.selectTwoChoice(titleA: titleA, titleB: titleB) {
                try! self.realm.write({
                    self.dataSet.list.removeAll()
                })
                self.realmWrite(title, flag, colorIndex)
                self.setAndDismiss(homeVC)
                print("データを更新しました。")
            }
            referenceVC.present(alertVC, animated: true, completion: nil)
        }
    }
    // データベースへの書き込み
    private func realmWrite(_ title: String, _ flag: Bool, _ colorIndex: Int ) {
        // titleのデータの保存、更新
        try! realm.write({
            dataSet.title = title
            dataSet.randomFlag = flag
            dataSet.colorIndex = colorIndex
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
    // データをセットして閉じる
    private func setAndDismiss(_ homeVC: HomeViewController) {
        if homeVC.dataSet == nil {
            homeVC.startButton.titleLabel?.removeFromSuperview()
            homeVC.view.addSubview(homeVC.startLabel)
        }
        homeVC.dataSet = dataSet
        homeVC.rouletteTitleLabel.text = dataSet.title.isEmpty ? "No title": dataSet.title
        homeVC.newDataButton.isSelected = false
        homeVC.setDataButton.isSelected = false
        referenceVC.statusBarStyleChange(style: .darkContent)
        try! realm.write({
            // Dateを保存して起動時に最後にセットしたデータをセットする
            dataSet.lastDate = Date()
        })
        referenceVC.dismiss(animated: true, completion: nil)
    }
    // ウィンドウを閉じる
    func closeWindow() {
        let alertVC = UIAlertController(title: .none, message: "編集を中止してウィンドウを閉じますか？", preferredStyle: .actionSheet)
        let titleA = "編集を続ける", titleB = "ウィンドウを閉じる"
        alertVC.selectTwoChoice(titleA: titleA, titleB: titleB) {
            guard let nav = self.referenceVC.presentingViewController as? UINavigationController,
                  let homeVC = nav.topViewController as? HomeViewController else { return print("NG") }
            // Newボタンから遷移
            if homeVC.newDataButton.isSelected {
                homeVC.newDataButton.isSelected = false
                self.referenceVC.statusBarStyleChange(style: .darkContent)
                self.referenceVC.dismiss(animated: true, completion: nil)
            } else if homeVC.setDataButton.isSelected {
                self.referenceVC.navigationController?.popViewController(animated: true)
            } else {
                self.referenceVC.statusBarStyleChange(style: .darkContent)
                self.referenceVC.dismiss(animated: true, completion: nil)
            }
        }
        referenceVC.present(alertVC, animated: true, completion: nil)
    }
}

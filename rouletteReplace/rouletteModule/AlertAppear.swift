//
//  AlertAppear.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/09.
//

import UIKit

class AlertAppear {
    private var input: InterfaceInput!
    init(input: InterfaceInput) {
        self.input = input
    }
    func appear() {
        let vc = input.vc as? RouletteViewController
        let alertVC = UIAlertController(title: .none, message: "ルーレットを中止しますか？", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        let action = UIAlertAction(title: "中止する", style: .default) { _ in
            vc?.dismiss(animated: true, completion: nil)
        }
        alertVC.addAction(cancel)
        alertVC.addAction(action)
        vc?.present(alertVC, animated: true, completion: nil)
    }
}
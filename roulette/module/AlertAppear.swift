//
//  AlertAppear.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/09.
//

import UIKit

class AlertAppear {
    static let shared = AlertAppear()
    func appear(input: UIViewController) {
        let alertVC = UIAlertController(title: .none, message: "ルーレットを中止しますか？", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        let action = UIAlertAction(title: "中止する", style: .default) { _ in
            input.dismiss(animated: true, completion: nil)
        }
        alertVC.addAction(cancel)
        alertVC.addAction(action)
        input.present(alertVC, animated: true, completion: nil)
    }
}

//
//  AlertAppear.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/09.
//

import UIKit

class AlertAppear {
    static let shared = AlertAppear()
    func suspension(vc: UIViewController) {
        let alertVC = UIAlertController(title: .none, message: "ルーレットを中止しますか？", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        let action = UIAlertAction(title: "中止する", style: .default) { _ in
            vc.dismiss(animated: true, completion: nil)
        }
        alertVC.addAction(cancel)
        alertVC.addAction(action)
        vc.present(alertVC, animated: true, completion: nil)
    }
    func cancel(vc: UIViewController) {
        let alertController = UIAlertController(title: .none, message: "現在セットされているデータは消せません", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        vc.present(alertController, animated: true, completion: nil)
    }
}

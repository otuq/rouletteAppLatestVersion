//
//  AlertAppear.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/09.
//

import UIKit

class AlertAppear {
    private var vc: UIViewController!
    init(with vc: UIViewController) {
        self.vc = vc
    }
    func alertAction(_ message: String, _ cancelTitle: String, _ executeTitle: String, execute: @escaping () -> Void) {
        let alertVC = UIAlertController(title: .none, message: message, preferredStyle: .alert)
        alertVC.selectJob(cancel: cancelTitle, execute: executeTitle) {
            execute()
        }
        vc.present(alertVC, animated: true, completion: nil)
    }
    func cancel() {
        let message = "現在セットされているデータは消せません", title = "OK"
        let alertController = UIAlertController(title: .none, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: title, style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        vc.present(alertController, animated: true, completion: nil)
    }
    func goBackHome() {
        let message = "編集を終了してウィンドウを閉じますか？"
        let cancelTitle = "編集を続ける", executeTitle = "ウィンドウを閉じる"
        alertAction(message, cancelTitle, executeTitle) {
            guard let nav = self.vc.presentingViewController as? UINavigationController,
                  let homeVC = nav.topViewController as? HomeViewController else { return print("NG") }
            // Newボタンから遷移
            if homeVC.newDataButton.isSelected {
                homeVC.newDataButton.isSelected = false
                self.vc.statusBarStyleChange(style: .darkContent)
                self.vc.dismiss(animated: true, completion: nil)
            } else if homeVC.setDataButton.isSelected {
                self.vc.navigationController?.popViewController(animated: true)
            } else {
                self.vc.statusBarStyleChange(style: .darkContent)
                self.vc.dismiss(animated: true, completion: nil)
            }
        }
    }
}

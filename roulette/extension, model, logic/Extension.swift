//
//  extension.swift
//  roulette
//
//  Created by USER on 2021/06/21.
//

import UIKit

extension UIButton {
    func accesory() {
        layer.cornerRadius = bounds.width / 2
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.darkGray.cgColor
        layer.shadowOffset = .init(width: 1, height: 1.5)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 1
    }
}
//チェーンレスポンダー
extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while true {
            guard let nextResponder = parentResponder?.next else { return nil }
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            parentResponder = nextResponder
        }
    }
}

extension UILabel {
    
    func rouletteTextLabel(angle: CGFloat, text: String) -> UILabel{
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.black
        ]
        //ルーレットの外枠からはみ出てしまい余白が欲しいのでラベルの短形サイズで調整
        bounds.size = CGSize(width: frame.width - frame.width / 10, height: frame.height)
        attributedText = NSAttributedString(string: text, attributes: attributes)
        transform = CGAffineTransform(rotationAngle: angle)
        return self
    }
}

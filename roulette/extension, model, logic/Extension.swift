//
//  extension.swift
//  roulette
//
//  Created by USER on 2021/06/21.
//

import UIKit

extension UIButton {
    //丸ボタンの装飾
    func accesory() {
        layer.cornerRadius = bounds.width / 2
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.darkGray.cgColor
        layer.shadowOffset = .init(width: 1, height: 1.5)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 1
        //透明になったり戻ったりのアニメーション　データがセットされた時発動
    }
}
extension UIView {
    //チェーンレスポンダー
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
    func rouletteTextSetting(_ text: String, _ textColor: UIColor,_ textAngle: CGFloat) {
        let textLabel = UILabel()
        textLabel.frame.size = CGSize(width: 150, height: 20)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: textColor
        ]
        textLabel.attributedText = NSAttributedString(string: text, attributes: attributes)
        //ルーレットの外枠からはみ出てしまい余白が欲しいのでラベルの短形サイズで調整
        addSubview(textLabel)
        transform = CGAffineTransform(rotationAngle: textAngle)
    }
}
extension UILabel {
    func accesory(bgColor: UIColor) {
        layer.backgroundColor = bgColor.cgColor
        layer.cornerRadius = bounds.width / 2
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.darkGray.cgColor
        layer.shadowOffset = .init(width: 1, height: 1.5)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 1
    }
}
extension NSAttributedString {
    convenience init(font: UIFont, color: UIColor, lineSpacing: CGFloat, alignment: NSTextAlignment, string: String) {
        var attribute: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        paragraphStyle.lineSpacing = lineSpacing
        attribute.updateValue(paragraphStyle, forKey: .paragraphStyle)
        self.init(string: string, attributes: attribute)
    }
}

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
    func rouletteTextLabel(_ angle: CGFloat, _ text: String, _ textColor: UIColor) -> UILabel{
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: textColor
        ]
        //ルーレットの外枠からはみ出てしまい余白が欲しいのでラベルの短形サイズで調整
        bounds.size = CGSize(width: frame.width - frame.width / 10, height: frame.height)
        attributedText = NSAttributedString(string: text, attributes: attributes)
        transform = CGAffineTransform(rotationAngle: angle)
        return self
    }
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
extension UIColor {
    
    var r: Int {
        Int(self.cgColor.components![0] * 255)
    }
    var g: Int {
        Int(self.cgColor.components![1] * 255)
    }
    var b: Int {
        Int(self.cgColor.components![2] * 255)
    }
    var a: Int {
        Int(self.cgColor.components![3] * 255)
    }
    //rgb値を分割して取得
    convenience init(r: Int,g: Int, b: Int, a: CGFloat = 1.0){
        self.init(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: a)
    }
    
    class var paleBlue: UIColor {
        UIColor.init(r: 3, g: 157, b: 252)
    }
    class var paleRed: UIColor {
        UIColor.init(r: 252, g: 3, b: 157)
    }
    class var yellowGreen: UIColor {
        UIColor.init(r: 211, g: 252, b: 3)
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

//
//  extension.swift
//  roulette
//
//  Created by USER on 2021/06/21.
//

import UIKit

extension UINavigationController {
    open override var childForStatusBarStyle: UIViewController? {
        return visibleViewController
    }
    func statusBarDark() {
        
    }
}
extension UIButton {
    func homeButtonDecoration() {
        let imageNormal = UIImage(named: "buttonNormal")
        let imageHighlight = UIImage(named: "buttonHighlight")
        setBackgroundImage(imageNormal, for: .normal)
        setBackgroundImage(imageHighlight, for: .highlighted)
        
    }
    //丸ボタンの装飾
    func decoration() {
        layer.cornerRadius = bounds.width / 2
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.darkGray.cgColor
        layer.shadowOffset = .init(width: 1, height: 1.5)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 1
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
    func rouletteTextSetting(_ text: String, _ textColor: UIColor,_ textAngle: CGFloat, textSize: CGFloat) {
        let textLabel = UILabel()
        textLabel.frame.size = CGSize(width: 150, height: 20)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: textSize),
            .foregroundColor: textColor
        ]
        textLabel.attributedText = NSAttributedString(string: text, attributes: attributes)
        //ルーレットの外枠からはみ出てしまい余白が欲しいのでラベルの短形サイズで調整
        addSubview(textLabel)
        transform = CGAffineTransform(rotationAngle: textAngle)
    }
}
extension UIViewController {
    //ステータスバーの色スタイルを動的に変更する
    func statusBarStyleChange(style: UIStatusBarStyle) {
        guard let nav = presentingViewController as? UINavigationController,
              let rootVC = nav.viewControllers.first as? HomeViewController else { return }
        rootVC.statusBarStyleChange = style
        UIView.animate(withDuration: 1) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
}
extension UILabel {
    func decoration(bgColor: UIColor) {
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
//extension UITextField {
//    func decoration(placeholderString: String) {
//        attributedPlaceholder = NSAttributedString(string: placeholderString, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightestGray])
//        borderStyle = .none
//        //文字の左端に余白を設ける
//        if textAlignment == .left || textAlignment == .natural {
//            leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
//            leftViewMode = .always
//        }
//        layer.borderColor = UIColor.lightestGray.cgColor
//        layer.borderWidth = 1
//        layer.cornerRadius = 5
//        layer.masksToBounds = true
//    }
//}

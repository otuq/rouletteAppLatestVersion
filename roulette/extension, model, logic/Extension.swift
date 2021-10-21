//
//  extension.swift
//  roulette
//
//  Created by USER on 2021/06/21.
//

import UIKit


extension UIButton {
    func imageSet() {
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
    //randomボタンのonoffを判定する
    private struct flagFunc {
        static var flag: Bool = true
    }
    var flag: Bool {
        get {
            guard let hoge = objc_getAssociatedObject(self, &flagFunc.flag)as? Bool else { return true }
            return hoge
        }
        set {
            objc_setAssociatedObject(self, &flagFunc.flag, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
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
    func rouletteTextSetting(width: CGFloat, height: CGFloat,_ text: String, _ textColor: UIColor,_ textAngle: CGFloat, textSize: CGFloat) {
        let textLabel = UILabel()
        textLabel.frame.size = CGSize(width: width, height: height)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: textSize),
            .foregroundColor: textColor
        ]
        textLabel.attributedText = NSAttributedString(string: text, attributes: attributes)
        addSubview(textLabel)
        transform = CGAffineTransform(rotationAngle: textAngle)
    }
}
extension UIViewController {
    //ステータスバーの色スタイルを動的に変更する
    func statusBarStyleChange(style: UIStatusBarStyle) {
        //インターフェースがダークモードに設定されている時に発動
        if UITraitCollection.current.userInterfaceStyle == .dark {
            guard let nav = presentingViewController as? UINavigationController,
                  let rootVC = nav.viewControllers.first as? HomeViewController else { return }
            rootVC.statusBarStyleChange = style
            UIView.animate(withDuration: 1) {
                self.setNeedsStatusBarAppearanceUpdate()
            }
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
extension String {
    func textSizeCalc(width: CGFloat, attribute: [NSAttributedString.Key: Any]) -> CGSize {
        let bounds = CGSize(width: width, height: .greatestFiniteMagnitude)
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let rect = (self as NSString).boundingRect(with: bounds, options: options, attributes: attribute, context: nil)
        let size = CGSize(width: rect.size.width, height: rect.size.height)
        return size
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

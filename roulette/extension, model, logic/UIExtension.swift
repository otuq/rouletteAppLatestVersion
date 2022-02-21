//
//  UIExtension.swift
//  roulette
//
//  Created by USER on 2022/02/21.
//

import UIKit


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
extension UIAlertController {
    func selectTwoChoice(titleA: String, titleB: String, action: @escaping ()->()) {
        let actionA = UIAlertAction(title: titleA, style: .cancel, handler: .none)
        let actionB = UIAlertAction(title: titleB, style: .default) { _ in
            action()
        }
        addAction(actionA)
        addAction(actionB)
    }
}
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
    //UIButtonのテキストサイズをデバイス毎に再計算する
    func fontSizeRecalcForEachDevice() {
        if let font = titleLabel?.font {
            titleLabel?.font = UIFont.systemFont(ofSize: font.pointSize.recalcValue, weight: font.weight)
        }
        let insetValue: CGFloat = 20
        let recalcValue = insetValue.recalcValue
        contentMode = .scaleAspectFit
        imageEdgeInsets = UIEdgeInsets(top: recalcValue, left: recalcValue, bottom: recalcValue, right: recalcValue)
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
    //UILabelのテキストサイズをデバイス毎に再計算する
    func fontSizeRecalcForEachDevice() {
        font = UIFont.systemFont(ofSize: font.pointSize.recalcValue, weight: font.weight)
    }
}
extension UIFont {
    //UIFontの装飾の情報を取得する
    private var traits: [UIFontDescriptor.TraitKey: Any] {
        fontDescriptor.object(forKey: .traits)as? [UIFontDescriptor.TraitKey: Any] ?? [:]
    }
    //文字の太さを取得
    var weight: UIFont.Weight {
        guard let weight = traits[.weight]as? NSNumber else { return .regular}
        return UIFont.Weight(rawValue: CGFloat(truncating: weight))
    }
}

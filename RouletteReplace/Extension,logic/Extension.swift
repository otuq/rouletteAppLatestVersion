//
//  extension.swift
//  roulette
//
//  Created by USER on 2021/06/21.
//

import UIKit

extension String {
    // テキストサイズを再計算
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
extension CGFloat {
    // デバイス毎に再計算する
    var recalcValue: CGFloat {
        let refDeviceHeight: CGFloat = 812
        let deviceHeight: CGFloat = UIScreen.main.bounds.height
        let reCalc = refDeviceHeight / self
        if refDeviceHeight != deviceHeight {
            return deviceHeight / reCalc
        }
        return self
    }
}
extension Notification.Name {
    // SetDataVCのdidselectのindex
    static let indexPost = Notification.Name("indexPost")
}
// AutoLayoutをデバイス毎に再計算
class CustomLayoutConstant: NSLayoutConstraint {
    override var constant: CGFloat {
        get {
            super.constant.recalcValue
        }
        set {
            super.constant = newValue
        }
    }
}

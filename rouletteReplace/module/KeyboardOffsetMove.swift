//
//  Keyboard.swift
//  rouletteReplace
//
//  Created by USER on 2022/04/04.
//

import UIKit

class KeyboardOffsetMove {
    private var notification: Notification!
    private var overlap: CGFloat = 0.0
    private var lastOffset: CGFloat = 0.0
    private var contentHeight: CGFloat = 0.0
    
    init(notification: Notification) {
        self.notification = notification
    }
    
    func tableViewOffsetMove(fldFrame: CGRect, tb: UITableView, plusValue: CGFloat? = nil, calcValue: (_ overlap: CGFloat, _ lastOffset: CGFloat) -> Void) {
        let userInfo = (notification as NSNotification).userInfo!
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey]as! NSValue).cgRectValue // keyboardの座標を取得
        overlap = fldFrame.maxY - keyboardFrame.minY
        if overlap > 0 {
            let frameHeight = tb.frame.height
            let contentHeight = tb.contentSize.height
            let calcHeight = plusValue ?? 0.0
            // contentOffsetの最下を算出する。
            let limitOffset = frameHeight < contentHeight ? (contentHeight - frameHeight) + calcHeight : 0.0
            // 隠れている部分をoverlap分下げて見えるようにする。
            overlap += tb.contentOffset.y + 20
            tb.setContentOffset(CGPoint(x: 0, y: overlap), animated: true)
            // contentOffsetがlimitを超えてしまうとキーボードを閉じた時に余計にスクロールしたように表示されるので最下を超えないようにする。
            lastOffset = limitOffset < tb.contentOffset.y ? limitOffset : tb.contentOffset.y
            calcValue(overlap, lastOffset)
            print(limitOffset)
        }
        print("overlap: \(overlap), lastoffset: \(lastOffset)")
    }
}

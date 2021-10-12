//
//  addRowButton.swift
//  roulette
//
//  Created by USER on 2021/06/22.
//

import UIKit

protocol AddRowDelegate: AnyObject {
    func addRowInsert()
}
//tableViewのセルを追加するボタン
class AddRowButton: UIButton {
    static let shared = AddRowButton.init(frame: CGRect(origin: .zero, size: CGSize(width: 50, height: 50)))
    weak var delegate: AddRowDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        decoration()
        layer.backgroundColor = UIColor.init(r: 255, g: 31, b: 169).cgColor //255, 31, 169
        setTitle("＋", for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 24)
        titleLabel?.baselineAdjustment = .alignCenters
        addTarget(self, action: #selector(addRowDelegate), for: .touchUpInside)
    }
    @objc func addRowDelegate() {
        delegate?.addRowInsert()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

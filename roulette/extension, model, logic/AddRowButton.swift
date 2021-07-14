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
    //MARK:-properties
    static let shared = AddRowButton.init(frame: CGRect(origin: .zero, size: CGSize(width: 50, height: 50)))
    weak var delegate: AddRowDelegate?
    
    //MARK:-LyfeCycle Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.backgroundColor = UIColor.lightGray.cgColor
        layer.opacity = 0.5
        layer.borderWidth = 0.5
        layer.cornerRadius = bounds.width / 2
        layer.shadowOffset = .init(width: 1, height: 1.5)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 1
        addTarget(self, action: #selector(addRowDelegate), for: .touchUpInside)
    }
    @objc func addRowDelegate() {
        delegate?.addRowInsert()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

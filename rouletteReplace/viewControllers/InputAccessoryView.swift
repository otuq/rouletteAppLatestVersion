//
//  InputAccessoryView.swift
//  roulette
//
//  Created by USER on 2021/12/20.
//

import UIKit

protocol InputAccessoryViewDelegate: AnyObject {
    func textFieldEndEditingButton()
}
class InputAccessoryView: UIView {
    // MARK: Properties
    weak var delegate: InputAccessoryViewDelegate?

    // MARK: Outlets,actions
    @IBOutlet var doneButton: UIButton!

    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        initNib()
        settingView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Methods
    private func initNib() {
        let nib = UINib(nibName: "InputAccessoryView", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view)
    }
    private func settingView() {
        doneButton.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
    }
    @objc private func tapAction() {
        delegate?.textFieldEndEditingButton()
    }
}

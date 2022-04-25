//
//  TableViewCell.swift
//  roulette
//
//  Created by USER on 2021/06/21.
//

import UIKit

class NewDataTableViewCell: UITableViewCell, UIViewControllerTransitioningDelegate {
    // MARK: properties
    private let selectView = UIView()
    private let notification = NotificationCenter.default
    private var editField: UITextField?
    private var overlap: CGFloat = 0.0
    private var lastOffset: CGFloat = 0.0
    private var contentHeight: CGFloat = 0.0
    private var newDataVC: NewDataViewController { parentViewController as! NewDataViewController }
    private var cellIndex: Int { newDataVC.newDataTableView.indexPath(for: self)!.row }
    
    private lazy var inputAccessory: InputAccessoryView = {
        let view = InputAccessoryView()
        view.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 50)
        view.backgroundColor = .white.withAlphaComponent(0.9)
        view.delegate = self
        return view
    }()
    var graphDataTemporary: RouletteGraphTemporary? {
        didSet {
            guard let temporary = graphDataTemporary else { return }
            let rgb = temporary.rgbTemporary
            let text = temporary.textTemporary
            let ratio = temporary.ratioTemporary
            rouletteSetColorLabel.backgroundColor = UIColor(r: rgb["r"]!, g: rgb["g"]!, b: rgb["b"]!)
            rouletteTextField.text = text
            rouletteRatioSlider.value = ratio
            randomSwitchToggle()
        }
    }
    // MARK: Outlets,Actions
    @IBOutlet var rouletteSetColorLabel: UILabel!
    @IBOutlet var rouletteTextField: UITextField!
    @IBOutlet var rouletteRatioSlider: UISlider!
    
    // MARK: Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        overrideUserInterfaceStyle = .light
        settingGesture()
        self.settingUI()
        notification.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    override var inputAccessoryView: UIView? {
        inputAccessory
    }
    
    private func settingGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(colorSelectTransition))
        rouletteSetColorLabel.addGestureRecognizer(gesture)
        rouletteRatioSlider.addTarget(self, action: #selector(saveRatio), for: .touchUpInside)
        rouletteTextField.delegate = self
    }
    private func randomSwitchToggle() {
        if newDataVC.randomSwitchButton.flag {
            rouletteRatioSlider.isUserInteractionEnabled = false
            rouletteRatioSlider.layer.opacity = 0.3
        } else {
            rouletteRatioSlider.isUserInteractionEnabled = true
            rouletteRatioSlider.layer.opacity = 1
        }
    }
    private func settingUI() {
        backgroundColor = .clear
        selectView.backgroundColor = .clear
        selectedBackgroundView = selectView
        rouletteSetColorLabel.layer.cornerRadius = rouletteSetColorLabel.bounds.width / 2
        rouletteSetColorLabel.layer.masksToBounds = true
        rouletteSetColorLabel.layer.borderWidth = 0.5
        rouletteSetColorLabel.isUserInteractionEnabled = true
        rouletteTextField.isUserInteractionEnabled = true
    }
    @objc func saveRatio(sender: UISlider) {
        let temporary = newDataVC.graphTemporary(index: cellIndex)
        temporary.ratioTemporary = sender.value
    }
    @objc func colorSelectTransition() {
        let storyboard = UIStoryboard(name: R.storyboard.colorSelect.name, bundle: nil)
        let colorSelectVC = storyboard.instantiateInitialViewController { coder in
            let currentColor = self.rouletteSetColorLabel.backgroundColor
            return ColorSelectViewController(coder: coder, currentColor: currentColor, cellIndex: self.cellIndex)
        }
        // PresentationControllerをカスタマイズして色選択のモーダルウィンドウを作成
        if let colorSelectVC = colorSelectVC {
            colorSelectVC.transitioningDelegate = self
            colorSelectVC.modalPresentationStyle = .custom
            parentViewController?.present(colorSelectVC, animated: true, completion: nil)
        }
    }
    // PresentationControllerをカスタムするためのdelegateメソッド
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        ColorsSelectPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
// MARK: - TextFieldDelegate
extension NewDataTableViewCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        editField = textField
    }
    @objc func keyboardWillShow(notification: Notification) {
        guard let fld = editField else { return }
        // keyboardの座標を取得
        let fldFrame = newDataVC.view.convert(fld.frame, from: contentView) // textfieldの座標系をviewに合わせる
        let oparationViewHeight = newDataVC.operationView.frame.height
        let offsetMove = KeyboardOffsetMove(notification: notification)
        offsetMove.tableViewOffsetMove(fldFrame: fldFrame, tb: newDataVC.newDataTableView, plusValue: oparationViewHeight) { overlap, lastOffset in
            self.overlap = overlap
            self.lastOffset = lastOffset
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        editField = nil
        let temporary = newDataVC.graphTemporary(index: cellIndex)
        temporary.textTemporary = textField.text ?? ""
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // リターンキーを押したら次のtextFieldに移動。最後までいったらoffsetを戻し編集を終了する。
        if newDataVC.numberOfRows == cellIndex + 1 {
            newDataVC.newDataTableView.setContentOffset(CGPoint(x: 0, y: lastOffset), animated: true)
            textField.resignFirstResponder()
        } else {
            let indexPath = IndexPath(row: cellIndex + 1, section: 0)
            let nextCell = newDataVC.newDataTableView.cellForRow(at: indexPath)as? NewDataTableViewCell
            nextCell?.rouletteTextField.becomeFirstResponder()
        }
        return true
    }
}
// MARK: - InputAccessoryViewDelegate

extension NewDataTableViewCell: InputAccessoryViewDelegate {
    func textFieldEndEditingButton() {
        if overlap > 0 {
            newDataVC.newDataTableView.setContentOffset(CGPoint(x: 0, y: lastOffset), animated: true)
        }
        rouletteTextField.resignFirstResponder()
    }
}

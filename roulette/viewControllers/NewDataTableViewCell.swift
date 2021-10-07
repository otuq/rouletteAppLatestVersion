//
//  TableViewCell.swift
//  roulette
//
//  Created by USER on 2021/06/21.
//

import UIKit

class NewDataTableViewCell: UITableViewCell, UIViewControllerTransitioningDelegate {
    //MARK:-properties
    private let selectView = UIView()
    private var editField: UITextField?
    private var overlap: CGFloat = 0.0
    private var lastOffset: CGFloat = 0.0
    var graphDataTemporary: RouletteGraphTemporary? {
        didSet{
            guard let temporary = graphDataTemporary else { return }
            let rgb = temporary.rgbTemporary
            let text = temporary.textTemporary
            let ratio = temporary.ratioTemporary
            rouletteSetColor.backgroundColor = UIColor.init(r: rgb["r"]!, g: rgb["g"]!, b: rgb["b"]!)
            rouletteTextField.text = text
            rouletteRatioSlider.value = ratio
        }
    }
    //MARK:-Outlets,Actions
    @IBOutlet weak var rouletteSetColor: UILabel!
    @IBOutlet weak var rouletteTextField: UITextField!
    @IBOutlet weak var rouletteRatioSlider: UISlider!
    //MARK:-LifeCycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        settingUI()
        settingGesture()
        keyboardNotification()
    }
    private func settingUI() {
        backgroundColor = .clear
        selectView.backgroundColor = .clear
        selectedBackgroundView = selectView
        rouletteTextField.delegate = self
        rouletteSetColor.layer.cornerRadius = rouletteSetColor.bounds.width / 2
        rouletteSetColor.layer.masksToBounds = true
        rouletteSetColor.layer.borderWidth = 0.5
        rouletteSetColor.isUserInteractionEnabled = true
        rouletteTextField.isUserInteractionEnabled = true
    }
    private func settingGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(selectColorViewFetch))
        rouletteSetColor.addGestureRecognizer(gesture)
        rouletteRatioSlider.addTarget(self, action: #selector(saveRatio), for: .touchUpInside)
    }
    @objc func saveRatio(sender: UISlider) {
        guard let newDataVC = parentViewController as? NewDataViewController,
              let cellIndexPath = newDataVC.newDataTableView.indexPath(for: self) else { return }
        let row = cellIndexPath.row
        newDataVC.dataSet.temporarys[row].ratioTemporary = sender.value
    }
    @objc func selectColorViewFetch() {
        let storyboard = UIStoryboard(name: "ColorSelect", bundle: nil)
        let colorSelectVC = storyboard.instantiateViewController(withIdentifier: "ColorSelectViewController")as! ColorSelectViewController
        //PresentationControllerをカスタマイズして色選択のモーダルウィンドウを作成
        colorSelectVC.transitioningDelegate = self
        colorSelectVC.modalPresentationStyle = .custom
        //色のラベルをタップした時にタップされたセルのindex番号を取得する。セルをタップした場合はindexPathSelectRowを使うがラベルにタップした時には検出されないので下記のコードで取得する。
        guard let newDataVC = parentViewController as? NewDataViewController,
              let cellIndexPath = newDataVC.newDataTableView.indexPath(for: self) else { return }
        //cellのindex番号を遷移先のVCに渡す
        colorSelectVC.cellTag = cellIndexPath.row
        colorSelectVC.currentColor = rouletteSetColor.backgroundColor
        //親ViewControllerを取得　extensionにて
        parentViewController?.present(colorSelectVC, animated: true, completion: nil)
    }
    //PresentationControllerをカスタムするためのdelegateメソッド
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        ColorsSelectPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
//MARK: - TextFieldDelegate
extension NewDataTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let newDataVC = parentViewController as? NewDataViewController,
              let cellIndexPath = newDataVC.newDataTableView.indexPath(for: self) else { return }
        let row = cellIndexPath.row
        editField = nil
        newDataVC.dataSet.temporarys[row].textTemporary = textField.text ?? ""
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let newDataVC = parentViewController as? NewDataViewController,let tableView = newDataVC.newDataTableView{
            tableView.setContentOffset(CGPoint(x: 0, y: lastOffset), animated: true)
            endEditing(true)
        }
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        editField = textField
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        editField = textField
    }
}
//MARK: -KeyboardNotification
extension NewDataTableViewCell {
    private func keyboardNotification() {
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(keyboardFrameChange), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        notification.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    @objc func keyboardFrameChange(notification: Notification) {
        guard let fld = editField,
              let newDataVC = parentViewController as? NewDataViewController else { return }
        let userInfo = (notification as NSNotification).userInfo!
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey]as! NSValue).cgRectValue //keyboardの座標を取得
        let fldFrame = newDataVC.view.convert(fld.frame, from: contentView) //textfieldの座標系をviewに合わせる
        overlap = fldFrame.maxY - keyboardFrame.minY
        if overlap > 0 {
            guard let tableView = newDataVC.newDataTableView else { return }
            overlap += tableView.contentOffset.y + 20
            tableView.setContentOffset(CGPoint(x: 0, y: overlap), animated: true)
        }
    }
    @objc func keyboardWillShow(notification: Notification){
        guard let newDataVC = parentViewController as? NewDataViewController else { return }
        lastOffset = newDataVC.newDataTableView.contentOffset.y
    }
//    @objc func keyboardDidHide(notification: Notification){
//        guard let newDataVC = parentViewController as? NewDataViewController,
//              let tableView = newDataVC.newDataTableView else { return }
//        tableView.setContentOffset(CGPoint(x: 0, y: lastOffset), animated: true)
//    }
}

//
//  TableViewCell.swift
//  roulette
//
//  Created by USER on 2021/06/21.
//

import UIKit

class NewDataTableViewCell: UITableViewCell, UIViewControllerTransitioningDelegate {
    //MARK: -properties
    private let selectView = UIView()
    private let notification = NotificationCenter.default
    private var editField: UITextField?
    private var overlap: CGFloat = 0.0
    private var lastOffset: CGFloat = 0.0
    private var newDataVC: NewDataViewController { parentViewController as! NewDataViewController }
    private var cellIndex: Int { newDataVC.newDataTableView.indexPath(for: self)!.row } //現在のcellのindex番号
    var graphDataTemporary: RouletteGraphTemporary? {
        didSet{
            guard let temporary = graphDataTemporary else { return }
            let rgb = temporary.rgbTemporary
            let text = temporary.textTemporary
            let ratio = temporary.ratioTemporary
            rouletteSetColorLabel.backgroundColor = UIColor.init(r: rgb["r"]!, g: rgb["g"]!, b: rgb["b"]!)
            rouletteTextField.text = text
            rouletteRatioSlider.value = ratio
        }
    }
    private lazy var inputAccessory: InputAccessoryView = {
        let view = InputAccessoryView()
        view.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 50)
        view.delegate = self
        return view
    }()

    //MARK: -Outlets,Actions
    @IBOutlet weak var rouletteSetColorLabel: UILabel!
    @IBOutlet weak var rouletteTextField: UITextField!
    @IBOutlet weak var rouletteRatioSlider: UISlider!
    
    //MARK: -LifeCycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        overrideUserInterfaceStyle = .light
        settingDelegate()
        settingGesture()
        //CustomLayoutConstant（デバイス毎にAutoLayoutを再計算するカスタムメソッド）を設定しているためか描画のタイミングのずれがあって、rouletteSetColorLabelが狂うのでDispatchQueueで対応
        DispatchQueue.main.async {
            self.settingUI()
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //最初awakeFromNib、textFieldDidBeginEditingのタイミングで実行したけど正常に動作しないことがあった。setSelectedのタイミングが良いっぽい。
        notification.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    override var inputAccessoryView: UIView? {
        inputAccessory
    }
    private func settingDelegate() {
        rouletteTextField.delegate = self
    }
    private func settingGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(selectColorViewFetch))
        rouletteSetColorLabel.addGestureRecognizer(gesture)
        rouletteRatioSlider.addTarget(self, action: #selector(saveRatio), for: .touchUpInside)
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
        newDataVC.dataSet.temporarys[cellIndex].ratioTemporary = sender.value
    }
    @objc func selectColorViewFetch() {
        let storyboard = UIStoryboard(name: "ColorSelect", bundle: nil)
        let colorSelectVC = storyboard.instantiateViewController(withIdentifier: "ColorSelectViewController")as! ColorSelectViewController
        //PresentationControllerをカスタマイズして色選択のモーダルウィンドウを作成
        colorSelectVC.transitioningDelegate = self
        colorSelectVC.modalPresentationStyle = .custom
        //色のラベルをタップした時にタップされたセルのindex番号を取得する。セルをタップした場合はindexPathSelectRowを使うがラベルにタップした時には検出されないので下記のコードで取得する。
        //cellのindex番号を遷移先のVCに渡す
        colorSelectVC.cellTag = cellIndex
        colorSelectVC.currentColor = rouletteSetColorLabel.backgroundColor
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
        editField = nil
        newDataVC.dataSet.temporarys[cellIndex].textTemporary = textField.text ?? ""
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //リターンキーを押したら次のtextFieldにフォーカス。最後までいったらoffsetを戻しフォーカスを外す。
        if newDataVC.dataSet.temporarys.count == cellIndex + 1 {
            newDataVC.newDataTableView.setContentOffset(CGPoint(x: 0, y: lastOffset), animated: true)
            textField.resignFirstResponder()
        }else{
            let indexPath = IndexPath(row: cellIndex + 1, section: 0)
            let nextCell = newDataVC.newDataTableView.cellForRow(at: indexPath)as? NewDataTableViewCell
            nextCell?.rouletteTextField.becomeFirstResponder()
            //willShowで通知すると正常に動作しない時があるっぽいからこっちの通知を使う
            notification.addObserver(self, selector: #selector(keyboardDidChangeFrame), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
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
    @objc func keyboardWillShow(notification: Notification){
        calcFrameOverlap(notification: notification)
    }
    @objc func keyboardDidChangeFrame(notification : Notification) {
        calcFrameOverlap(notification: notification)
    }
    private func calcFrameOverlap(notification: Notification) {
        guard let fld = editField else { return }
        let userInfo = (notification as NSNotification).userInfo!
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey]as! NSValue).cgRectValue //keyboardの座標を取得
        let fldFrame = newDataVC.view.convert(fld.frame, from: contentView) //textfieldの座標系をviewに合わせる
        overlap = fldFrame.maxY - keyboardFrame.minY
        if overlap > 0 {
            guard let tableView = newDataVC.newDataTableView else { return }
            overlap += tableView.contentOffset.y + 20
            tableView.setContentOffset(CGPoint(x: 0, y: overlap), animated: true)
            lastOffset = newDataVC.newDataTableView.contentOffset.y
        }
    }
}
//MARK: -InputAccessoryViewDelegate

extension NewDataTableViewCell: InputAccessoryViewDelegate {
    func textFieldEndEditingButton() {
        newDataVC.newDataTableView.setContentOffset(CGPoint(x: 0, y: lastOffset), animated: true)
        editField?.resignFirstResponder()
    }
}

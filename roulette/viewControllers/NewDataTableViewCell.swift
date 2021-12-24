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
    private var contentHeight: CGFloat = 0.0
    private var newDataVC: NewDataViewController { parentViewController as! NewDataViewController }
    private var cellIndex: Int { newDataVC.newDataTableView.indexPath(for: self)!.row } //現在のcellのindex番号
    private lazy var inputAccessory: InputAccessoryView = {
        let view = InputAccessoryView()
        view.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 50)
        view.backgroundColor = .white.withAlphaComponent(0.9)
        view.delegate = self
        return view
    }()
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
    func textFieldDidBeginEditing(_ textField: UITextField) {
        editField = textField
    }
    @objc func keyboardWillShow(notification: Notification){
        guard let fld = editField else { return }
        let userInfo = (notification as NSNotification).userInfo!
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey]as! NSValue).cgRectValue //keyboardの座標を取得
        let fldFrame = newDataVC.view.convert(fld.frame, from: contentView) //textfieldの座標系をviewに合わせる
        overlap = fldFrame.maxY - keyboardFrame.minY
        if overlap > 0 {
            let tableView = newDataVC.newDataTableView!
            let frameHeight = tableView.frame.height
            let contentHeight = tableView.contentSize.height
            let operationHeight = newDataVC.operationView.frame.height
            //contentOffsetの最下を算出する。
            let limitOffset = frameHeight < contentHeight ? (contentHeight - frameHeight) + operationHeight : 0.0
            //隠れている部分をoverlap分下げて見えるようにする。
            overlap += tableView.contentOffset.y + 20
            tableView.setContentOffset(CGPoint(x: 0, y: overlap), animated: true)
            //contentOffsetがlimitを超えてしまうとキーボードを閉じた時に余計にスクロールしたように表示されるので最下を超えないようにする。
            lastOffset = limitOffset < tableView.contentOffset.y ? limitOffset : tableView.contentOffset.y
            print(limitOffset)
        }
        print("overlap: \(overlap), lastoffset: \(lastOffset)")
    }
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
        }
        return true
    }
}
//MARK: -InputAccessoryViewDelegate

extension NewDataTableViewCell: InputAccessoryViewDelegate {
    func textFieldEndEditingButton() {
        if overlap > 0 {
            newDataVC.newDataTableView.setContentOffset(CGPoint(x: 0, y: lastOffset), animated: true)
        }
        rouletteTextField.resignFirstResponder()
    }
}

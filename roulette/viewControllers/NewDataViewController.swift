//
//  NewViewController.swift
//  roulette
//
//  Created by USER on 2021/06/21.
//

import UIKit
import RealmSwift

//グラフデータの流れ方
//newData→temporarysに一時データを格納してsaveボタンを押された時にデータベースに保存
//loadData→setVC→list（データベースに保存したデータ）のデータをtemporarysに格納する。
class NewDataViewController: UIViewController, UITextFieldDelegate {
    //MARK: -properties
    private let cellId = "cellId"
    private let notification = NotificationCenter.default
    var userInfo: [AnyHashable: Any]?
    private var colorIndex = 0
    private var realm = try! Realm()
    private var getAllCells = [NewDataTableViewCell]()
    private var colors = [UIColor]()
    var dataSet = RouletteData()
    
    //MARK: -Outlets,Actions
    @IBOutlet weak var newDataTableView: UITableView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var addRowButton: UIButton!
    @IBOutlet weak var randomSwitchButton: UIButton!
    @IBOutlet weak var saveLabel: UILabel!
    @IBOutlet weak var addRowLabel: UILabel!
    @IBOutlet weak var randomSwitchLabel: UILabel!
    @IBOutlet weak var operationView: UIView!
    
    //MARK: -LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        settingView()
        settingUI()
        settingGesture()
        fontSizeRecalcForEachDevice()
        
    }
    private func settingView() {
        newDataTableView.delegate = self
        newDataTableView.dataSource = self
        newDataTableView.separatorStyle = .none
        newDataTableView.keyboardDismissMode = .interactive 
        newDataTableView.register(UINib(nibName: "NewDataTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        titleTextField.delegate = self
        statusBarStyleChange(style: .lightContent)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelBarButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editBarButton))
        
        notification.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        notification.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    private func settingUI(){
        titleTextField.text = dataSet.title
        titleTextField.overrideUserInterfaceStyle = .light
        randomSwitchButton.flag = dataSet.randomFlag
        colorIndex = dataSet.colorIndex
        stride(from: 0, to: 360, by: 18).forEach { i in
            let color = UIColor.hsvToRgb(h: Float(i), s: 128, v: 255)
            colors.append(color)
        }
        saveButton.imageSet()
        addRowButton.imageSet()
        randomSwitchButton.imageSet()
        DispatchQueue.main.async {
            self.randomSwitch()
        }
    }
    private func settingGesture() {
        saveButton.addTarget(self, action: #selector(saveRouletteData), for: .touchUpInside)
        addRowButton.addTarget(self, action: #selector(addRowInsert), for: .touchUpInside)
        randomSwitchButton.addTarget(self, action: #selector(randomRatio), for: .touchUpInside)
    }
    private func fontSizeRecalcForEachDevice() {
        saveButton.fontSizeRecalcForEachDevice()
        saveLabel.fontSizeRecalcForEachDevice()
        addRowButton.fontSizeRecalcForEachDevice()
        addRowLabel.fontSizeRecalcForEachDevice()
        randomSwitchButton.fontSizeRecalcForEachDevice()
        randomSwitchLabel.fontSizeRecalcForEachDevice()
    }
    @objc private func addRowInsert() {
        let indexPath = IndexPath(row: 0, section: 0)
        let addRow = RouletteGraphTemporary()
        let rgb = colors[colorIndex]
        addRow.rgbTemporary = ["r": rgb.r, "g": rgb.g, "b": rgb.b]
        colorIndex = colorIndex < colors.count  - 1 ? colorIndex + 1 : 0
        //先頭から行を追加していく
        dataSet.temporarys.insert(addRow, at: 0)
        newDataTableView.insertRows(at: [indexPath], with: .fade)
        newDataTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        newDataTableView.contentInset.bottom = newDataTableView.frame.height - newDataTableView.contentSize.height
        randomSwitch()
    }
    @objc private func cancelBarButton() {
        let alertController = UIAlertController(title: .none, message: "編集を中止してウィンドウを閉じますか？", preferredStyle: .actionSheet)
        let actionA = UIAlertAction(title: "編集を続ける", style: .cancel, handler: .none)
        let actionB = UIAlertAction(title: "ウィンドウを閉じる", style: .default) { _ in
            guard let nav = self.presentingViewController as? UINavigationController,
                  let homeVC = nav.viewControllers.first as? HomeViewController else { return }
            //Newボタンから遷移
            if homeVC.newDataButton.isSelected {
                homeVC.newDataButton.isSelected = false
                self.statusBarStyleChange(style: .darkContent)
                self.dismiss(animated: true, completion: nil)
            }else if homeVC.setDataButton.isSelected {
                self.navigationController?.popViewController(animated: true)
            }else{
                self.statusBarStyleChange(style: .darkContent)
                self.dismiss(animated: true, completion: nil)
            }
        }
        alertController.addAction(actionA)
        alertController.addAction(actionB)
        present(alertController, animated: true, completion: nil)
    }
    @objc private func editBarButton() {
        newDataTableView.setEditing(true, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(editBarButtonDone))
    }
    @objc private func editBarButtonDone() {
        newDataTableView.setEditing(false, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editBarButton))
    }
    @objc private func randomRatio() {
        randomSwitchButton.flag = !randomSwitchButton.flag
        randomSwitch()
    }
    private func randomSwitch() {
        if randomSwitchButton.flag {
            randomSwitchLabel.text = "ON"
            getAllCells.enumerated().forEach { (index,cell) in
                cell.rouletteRatioSlider.isUserInteractionEnabled = false
                cell.rouletteRatioSlider.layer.opacity = 0.3
            }
        }else{
            randomSwitchLabel.text = "OFF"
            getAllCells.enumerated().forEach { (index,cell) in
                cell.rouletteRatioSlider.isUserInteractionEnabled = true
                cell.rouletteRatioSlider.layer.opacity = 1
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField)  -> Bool {
        view.endEditing(true)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //keyboardが表示している時はinsetをkeyboardのframe、非表示の時はoperationViewのframe。keyboardが表示されている時でも最下のcellまでスクロールできるようにする。
        if userInfo != nil {
            let keyboardFrame = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey]as! NSValue).cgRectValue //keyboardの座標を取得
            newDataTableView.contentInset.bottom = keyboardFrame.size.height
        }else{
            newDataTableView.contentInset.bottom = operationView.frame.height //スクロールした時の停止位置を指定。セルがoperationViewに被らないようにする。
        }
    }
    @objc private func keyboardWillShow(notification: Notification) {
        userInfo = (notification as NSNotification).userInfo
        print("show")
    }
    @objc private func keyboardDidHide() {
        userInfo = nil
    }
}
//MARK: -TableViewDelegate,Datasource
extension NewDataViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)  -> Int {
        dataSet.temporarys.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)as! NewDataTableViewCell
        let temporary = dataSet.temporarys[indexPath.row]
        cell.graphDataTemporary = temporary
        getAllCells.append(cell)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(80).recalcValue
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            dataSet.temporarys.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true //セルのドラッグ＆ドロップを有効
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let data = dataSet.temporarys[sourceIndexPath.row]
        dataSet.temporarys.remove(at: sourceIndexPath.row)
        dataSet.temporarys.insert(data, at: destinationIndexPath.row)
    }
}
//MARK: -ButtonActionMethods
extension NewDataViewController {
    @objc private func saveRouletteData() {
        guard let nav = presentingViewController as? UINavigationController,
              let homeVC = nav.topViewController as? HomeViewController else { return }
        if dataSet.temporarys.isEmpty { return }
        view.endEditing(true)
        //新規データの作成
        if homeVC.newDataButton.isSelected{
            realmWrite()
            try! realm.write({
                //データにIDを付ける。現在セット中のデータを削除できないようにするため。
                dataSet.dataId = NSUUID().uuidString
                dataSet.date = Date()
                realm.add(dataSet)
            })
            self.setAndDismiss(homeVC)
            print("データを新規作成しました。")
            //データセットの更新
        }else if homeVC.setDataButton.isSelected{
            let alertVC = UIAlertController(title: .none, message: "データを保存してセットしますか？", preferredStyle: .actionSheet)
            let updataSetAction = UIAlertAction(title: "保存してセットする", style: .default) { _ in
                try! self.realm.write({
                    self.dataSet.list.removeAll()
                })
                self.realmWrite()
                self.setAndDismiss(homeVC)
                print("データを更新しました。")
            }
            let cancelAction = UIAlertAction(title: "編集を続ける", style: .cancel, handler: nil)
            alertVC.addAction(updataSetAction)
            alertVC.addAction(cancelAction)
            self.present(alertVC, animated: true, completion: nil)
            //homeVCにセットしてあるデータの更新
        }else{
            let alertVC = UIAlertController(title: .none, message: "データを上書きしますか？", preferredStyle: .actionSheet)
            let updataSetAction = UIAlertAction(title: "上書きする", style: .default) { _ in
                try! self.realm.write({
                    self.dataSet.list.removeAll()
                })
                self.realmWrite()
                self.setAndDismiss(homeVC)
                print("データを更新しました。")
            }
            let cancelAction = UIAlertAction(title: "編集を続ける", style: .cancel, handler: nil)
            alertVC.addAction(updataSetAction)
            alertVC.addAction(cancelAction)
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    //データベースへの書き込み
    private func realmWrite() {
        //titleのデータの保存、更新
        try! realm.write({
            dataSet.title = titleTextField.text ?? ""
            dataSet.randomFlag = randomSwitchButton.flag
            dataSet.colorIndex = colorIndex
        })
        //cellの情報のデータの保存、更新
        dataSet.temporarys.enumerated().forEach { (index, temporary) in
            try! realm.write({
                dataSet.list.insert(RouletteGraphData(), at: index)
                let list = dataSet.list[index]
                list.text = temporary.textTemporary
                list.r = temporary.rgbTemporary["r"]!
                list.g = temporary.rgbTemporary["g"]!
                list.b = temporary.rgbTemporary["b"]!
                list.ratio = temporary.ratioTemporary
            })
        }
    }
    private func setAndDismiss(_ homeVC: HomeViewController) {
        if homeVC.dataSet == nil  {
            homeVC.startButton.titleLabel?.removeFromSuperview()
            homeVC.view.addSubview(homeVC.startLabel)
        }
        homeVC.dataSet = dataSet
        homeVC.rouletteTitleLabel.text = dataSet.title.isEmpty ? "No title": dataSet.title
        homeVC.newDataButton.isSelected = false
        homeVC.setDataButton.isSelected = false
        statusBarStyleChange(style: .darkContent)
        try! realm.write({
            //Dateを保存して起動時に最後にセットしたデータをセットする
            dataSet.lastDate = Date()
        })
        dismiss(animated: true, completion: nil)
    }
}

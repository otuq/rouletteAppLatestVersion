//
//  EditViewController.swift
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
    //MARK:-properties
    private let cellId = "cellId"
    //    private let colors: [UIColor] = [.blue,.red,.yellow,.green,.purple,.brown,.cyan,.magenta,.orange,.paleBlue,.paleRed,.yellowGreen]
    private var colors: [UIColor] {
        var colors = [UIColor]()
        stride(from: 0, to: 360, by: 18).forEach { i in
            let color = UIColor.hsvToRgb(h: Float(i), s: 128, v: 255)
            colors.append(color)
        }
        return colors
    }
    private var colorIndex = 0
    private var realm = try! Realm()
    //    private var addRowButton: AddRowButton {
    //        let addRowButton = AddRowButton.shared
    //        let xPoint = view.center.x - addRowButton.bounds.width / 2
    //        let yPoint = view.frame.maxY - view.frame.maxY / 6
    //        addRowButton.frame.origin = CGPoint(x: xPoint, y: yPoint )
    //        addRowButton.delegate = self
    //        return addRowButton
    //    }
    private var getAllCells = [NewDataTableViewCell]()
    var dataSet = RouletteData()
    
    //MARK:-Outlets,Actions
    @IBOutlet weak var newDataTableView: UITableView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var addRowButton: UIButton!
    @IBOutlet weak var randomSwitchButton: UIButton!
    @IBOutlet weak var randomSwitchLabel: UILabel!
    @IBOutlet weak var operationView: UIView!
    
    //MARK:-LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        settingView()
        settingGesture()
        settingUI()
    }
    private func settingView() {
        newDataTableView.delegate = self
        newDataTableView.dataSource = self
        newDataTableView.separatorStyle = .none
        newDataTableView.keyboardDismissMode = .interactive 
        newDataTableView.register(UINib(nibName: "NewDataTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        titleTextField.delegate = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelRouletteSets))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editRouletteSets))
    }
    private func settingUI(){
        titleTextField.text = dataSet.title
        titleTextField.overrideUserInterfaceStyle = .light
        randomSwitchButton.isSelected = dataSet.randomFlag
        saveButton.homeButtonDecoration()
        addRowButton.homeButtonDecoration()
        randomSwitchButton.homeButtonDecoration()
        
        DispatchQueue.main.async {
            self.randomSwitch()
        }
    }
    private func settingGesture() {
        saveButton.addTarget(self, action: #selector(saveRouletteData), for: .touchUpInside)
        addRowButton.addTarget(self, action: #selector(addRowInsert), for: .touchUpInside)
        randomSwitchButton.addTarget(self, action: #selector(randomRatio), for: .touchUpInside)
        
    }
    private func randomSwitch() {
        if randomSwitchButton.isSelected {
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
    @objc private func addRowInsert() {
        let indexPath = IndexPath(row: 0, section: 0)
        let addRow = RouletteGraphTemporary()
        let rgb = colors[colorIndex]
        addRow.rgbTemporary = ["r": rgb.r, "g": rgb.g, "b": rgb.b]
        colorIndex = colorIndex < colors.count - 1 ? colorIndex + 1 : 0
        //先頭から行を追加していく
        dataSet.temporarys.insert(addRow, at: 0)
        newDataTableView.insertRows(at: [indexPath], with: .fade)
        newDataTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        randomSwitch()
    }
    @objc private func cancelRouletteSets() {
        let alertController = UIAlertController(title: .none, message: "編集を中止してウィンドウを閉じますか？", preferredStyle: .alert)
        let actionA = UIAlertAction(title: "キャンセル", style: .cancel, handler: .none)
        let actionB = UIAlertAction(title: "閉じる", style: .default) { _ in
            let count = (self.navigationController?.viewControllers.count)! - 2
            if count < 0 {
                self.dismiss(animated: true, completion: nil)
            }else{
                self.navigationController?.popViewController(animated: true)
            }
        }
        alertController.addAction(actionA)
        alertController.addAction(actionB)
        present(alertController, animated: true, completion: nil)
    }
    @objc private func editRouletteSets() {
        newDataTableView.setEditing(true, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editRouletteSetsDone))
    }
    @objc private func editRouletteSetsDone() {
        newDataTableView.setEditing(false, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editRouletteSets))
    }
    @objc private func randomRatio() {
        randomSwitchButton.isSelected = !randomSwitchButton.isSelected
        randomSwitch()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let frameHeight = scrollView.frame.height
        let contentHeight = scrollView.contentSize.height
        //一番下までスクロールしたらUIで隠れている
        let offset = scrollView.contentOffset.y
        let calcContentHeight = contentHeight - frameHeight
        if contentHeight >= frameHeight {
            if offset >= calcContentHeight {
                newDataTableView.contentInset.bottom = offset < operationView.frame.height ? offset - calcContentHeight : operationView.frame.height
            }
        }
        //            //セルを追加していきcontentSizeがframeheightより大きくなった場合に発動
        //            if frameHeight <= contentHeight {
        //                scrollDidEndRemoveAddRow(scrollView)
        //            }
    }
    //一番下までスクロールしたらaddボタンを退場
    //    private func scrollDidEndRemoveAddRow(_ scrollView: UIScrollView) {
    //        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.height) {
    //            UIView.animate(withDuration: 1) {
    //                //CGAffinetransformではうまく動いてくれなかった。
    //                self.addRowButton.frame.origin.y = self.view.frame.maxY + 50
    //            }
    //        }else{
    //            UIView.animate(withDuration: 1) {
    //                self.addRowButton.transform = .identity
    //            }
    //        }
    //    }
}
//MARK:-TableViewDelegate,Datasource
extension NewDataViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        80
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
//MARK:-AddRowDelegate
//extension NewDataViewController: AddRowDelegate {
//    func addRowInsert() {
//        let indexPath = IndexPath(row: 0, section: 0)
//        let addRow = RouletteGraphTemporary()
//        let rgb = colors[colorIndex]
//        addRow.rgbTemporary = ["r": rgb.r, "g": rgb.g, "b": rgb.b]
//        colorIndex = colorIndex < colors.count - 1 ? colorIndex + 1 : 0
//        //先頭から行を追加していく
//        dataSet.temporarys.insert(addRow, at: 0)
//        newDataTableView.insertRows(at: [indexPath], with: .fade)
//        newDataTableView.scrollToRow(at: indexPath, at: .top, animated: true)
//        randomSwitch()
//    }
//}
//MARK:- ButtonActionMethods
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
                realm.add(dataSet)
            })
            self.setAndDismiss(homeVC)
            print("データを新規作成しました。")
            //データセットの更新
        }else if homeVC.setDataButton.isSelected{
            let alertVC = UIAlertController(title: "データセット", message: "", preferredStyle: .alert)
            let updataSetAction = UIAlertAction(title: "上書きしてセット", style: .default) { _ in
                try! self.realm.write({
                    self.dataSet.list.removeAll()
                })
                self.realmWrite()
                self.setAndDismiss(homeVC)
                print("データを更新しました。")
            }
            let setAction = UIAlertAction(title: "保存せずにセット", style: .default) { _ in
                self.withoutSavingSet()
                self.setAndDismiss(homeVC)
            }
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
            alertVC.addAction(updataSetAction)
            alertVC.addAction(setAction)
            alertVC.addAction(cancelAction)
            self.present(alertVC, animated: true, completion: nil)
            //homeVCにセットしてあるデータの更新
        }else{
            let alertVC = UIAlertController(title: "データの上書き", message: "", preferredStyle: .alert)
            let updataSetAction = UIAlertAction(title: "上書きをする", style: .default) { _ in
                try! self.realm.write({
                    self.dataSet.list.removeAll()
                })
                self.realmWrite()
                self.setAndDismiss(homeVC)
                print("データを更新しました。")
            }
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
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
            dataSet.randomFlag = randomSwitchButton.isSelected
            dataSet.date = Date()
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
    //保存をしないで元のデータでセット。
    private func withoutSavingSet() {
        dataSet.temporarys.removeAll()
        dataSet.list.forEach { list in
            let temporary = RouletteGraphTemporary()
            temporary.textTemporary = list.text
            temporary.rgbTemporary["r"] = list.r
            temporary.rgbTemporary["g"] = list.g
            temporary.rgbTemporary["b"] = list.b
            temporary.ratioTemporary = list.ratio
            dataSet.temporarys.append(temporary)
        }
    }
    private func setAndDismiss(_ homeVC: HomeViewController) {
        if homeVC.dataSet == nil  {
            homeVC.startButton.titleLabel?.removeFromSuperview()
            homeVC.view.addSubview(homeVC.setDataLabel)
        }
        homeVC.dataSet = dataSet
        homeVC.rouletteTitleLabel.text = dataSet.title.isEmpty ? "No title": dataSet.title
        homeVC.newDataButton.isSelected = false
        homeVC.setDataButton.isSelected = false
        dismiss(animated: true, completion: nil)
    }
}

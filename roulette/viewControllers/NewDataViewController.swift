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
    private let colors: [UIColor] = [.blue,.red,.yellow,.green,.purple,.brown,.cyan,.magenta,.orange,.paleBlue,.paleRed,.yellowGreen]
    private var colorIndex = 0
    private var realm: Realm {
        var config = Realm.Configuration()
        //migration データベースはデータモデルを変更すると新しいバージョンに移行処理を行わないとダメらしい。今は毎回バージョンが初期化される設定にしているが、リリースしてデータモデルを変更してアップデートする場合はmigrationを行う。現在バージョンが1で変更したらバージョンを2以下はmigration
        config.deleteRealmIfMigrationNeeded = true
        let realm = try! Realm(configuration: config)
        return realm
    }
    private var addRowButton: AddRowButton {
        let addRowButton = AddRowButton.shared
        let xPoint = view.center.x - addRowButton.bounds.width / 2
        let yPoint = view.frame.maxY - view.frame.maxY / 6
        addRowButton.frame.origin = CGPoint(x: xPoint, y: yPoint )
        addRowButton.setTitle("+", for: .normal)
        addRowButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        addRowButton.titleLabel?.baselineAdjustment = .alignCenters
        addRowButton.delegate = self
        return addRowButton
    }
    private var getAllCells = [TableViewCell]()
    var dataSet = RouletteData()
    
    //MARK:-Outlets,Actions
    @IBOutlet weak var newDataTableView: UITableView!
    @IBOutlet weak var titleTextView: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var randomSwitchButton: UIButton!
    @IBOutlet weak var randomSwitchLabel: UILabel!
    
    //MARK:-LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingView()
        settingUI()
    }
    private func settingView() {
        newDataTableView.delegate = self
        newDataTableView.dataSource = self
        newDataTableView.separatorStyle = .none
        newDataTableView.keyboardDismissMode = .interactive 
        newDataTableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        titleTextView.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editRouletteSets))
        self.view.addSubview(addRowButton)
    }
    @objc private func editRouletteSets() {
        newDataTableView.setEditing(true, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editRouletteSetsDone))
    }
    @objc private func editRouletteSetsDone() {
        newDataTableView.setEditing(false, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editRouletteSets))
    }
    private func settingUI(){
        titleTextView.text = dataSet.title
        randomSwitchButton.isSelected = dataSet.randomFlag
        randomSwitchButton.addTarget(self, action: #selector(randomRatio), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveRouletteData), for: .touchUpInside)
        saveButton.accesory()
        randomSwitchButton.accesory()
        DispatchQueue.main.async {
            self.randomSwitch()
        }
    }
    @objc private func randomRatio() {
        randomSwitchButton.isSelected = !randomSwitchButton.isSelected
        randomSwitch()
    }
    private func randomSwitch() {
//        guard let cells = newDataTableView.visibleCells as? [TableViewCell] else { return } //visiblecellsは完全に表示されているセルの意味らしい
        if randomSwitchButton.isSelected {
            randomSwitchButton.backgroundColor = .lightGray
            randomSwitchLabel.text = "ON"
            getAllCells.enumerated().forEach { (index,cell) in
                cell.rouletteRatioSlider.isUserInteractionEnabled = false
                cell.rouletteRatioSlider.layer.opacity = 0.3
            }
        }else{
            randomSwitchButton.backgroundColor = UIColor.init(r: 255, g: 64, b: 255)
            randomSwitchLabel.text = "OFF"
            getAllCells.enumerated().forEach { (index,cell) in
                cell.rouletteRatioSlider.isUserInteractionEnabled = true
                cell.rouletteRatioSlider.layer.opacity = 1
            }
        }
    }
    //一番下までスクロールしたらaddボタンを退場
    private func scrollDidEndRemoveAddRow(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y, (scrollView.contentSize.height - scrollView.frame.height) )
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.height) {
            UIView.animate(withDuration: 1) {
                //CGAffinetransformではうまく動いてくれなかった。
                self.addRowButton.frame.origin.y = self.view.frame.maxY + 50
            }
        }else{
            UIView.animate(withDuration: 1) {
                self.addRowButton.transform = .identity
            }
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let frameHeight = scrollView.frame.height
        let contentHeight = scrollView.contentSize.height
        //セルを追加していきcontentSizeがframeheightより大きくなった場合に発動
        if frameHeight <= contentHeight {
            scrollDidEndRemoveAddRow(scrollView)
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
}
//MARK:-TableViewDelegate,Datasource
extension NewDataViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSet.temporarys.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)as! TableViewCell
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
extension NewDataViewController: AddRowDelegate {
    func addRowInsert() {
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
}
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
            let setAction = UIAlertAction(title: "保存せずにセット", style: .default) { _ in
                self.withoutSavingSet()
                self.setAndDismiss(homeVC)
            }
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
            alertVC.addAction(updataSetAction)
            alertVC.addAction(setAction)
            alertVC.addAction(cancelAction)
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    private func realmWrite() {
        //titleのデータの保存、更新
        try! realm.write({
            dataSet.title = titleTextView.text ?? ""
            dataSet.randomFlag = randomSwitchButton.isSelected
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
        homeVC.dataSet = dataSet
        homeVC.rouletteTitleLabel.text = dataSet.title.isEmpty ? "No title": dataSet.title
        homeVC.newDataButton.isSelected = false
        homeVC.setDataButton.isSelected = false
        dismiss(animated: true, completion: nil)
    }
}

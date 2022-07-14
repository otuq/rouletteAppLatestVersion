//
//  NewViewController.swift
//  roulette
//
//  Created by USER on 2021/06/21.
//

import UIKit

protocol NewDataOutput: AnyObject {
    func setContents(dataSet: RouletteData)
    func saveContents(dataSet: RouletteData)
    func addRow() -> RouletteGraphTemporary
}
// protocolを定義してpresenterのプロパティやメソッドを他のファイルでも使えるように
protocol NewDataPresenterInput {
    var numberOfRows: Int { get }
    func graphTemporary(index: Int) -> RouletteGraphTemporary
}
class NewDataViewController: UIViewController, UITextFieldDelegate {
    // MARK: properties
    private let cellId = "cellId"
    private var colors = [UIColor]()
    private var colorIndex = 0
    private let notification = NotificationCenter.default
    private var userInfo: [AnyHashable: Any]?
    private var presenter: NewDataPresenter!
    var selectIndex: Int? // SetDataVCの選択されたセルのインデックスを受け取る
    
    // MARK: Outlets,Actions
    @IBOutlet private var titleTextField: UITextField!
    @IBOutlet private var saveButton: UIButton!
    @IBOutlet private var addRowButton: UIButton!
    @IBOutlet private var saveLabel: UILabel!
    @IBOutlet private var addRowLabel: UILabel!
    @IBOutlet private var randomSwitchLabel: UILabel!
    @IBOutlet var newDataTableView: UITableView!
    @IBOutlet var randomSwitchButton: UIButton!
    @IBOutlet var operationView: UIView!
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        settingView()
        settingUI()
        settingGesture()
        fontSizeRecalcForEachDevice()
    }
    private func initialize() {
        if let selectIndex = selectIndex {
            self.presenter = NewDataPresenter(with: self, index: selectIndex)
        } else {
        guard let nav = presentingViewController as? UINavigationController,
              let vc = nav.topViewController as? HomeViewController else { return }
            self.presenter = NewDataPresenter(with: self, selected: vc.selected)
        }
    }
    private func settingView() {
        newDataTableView.delegate = self
        newDataTableView.dataSource = self
        newDataTableView.separatorStyle = .none
        newDataTableView.keyboardDismissMode = .interactive
        
        newDataTableView.register(UINib(nibName: R.nib.newDataTableViewCell.name, bundle: nil), forCellReuseIdentifier: cellId)
        titleTextField.delegate = self
        statusBarStyleChange(style: .lightContent)
        randomSwitchButton.flag = presenter.randomSwitchFlag
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelBarButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editBarButton))
        
        notification.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        notification.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    @objc private func cancelBarButton() {
        let message = "編集を終了してウィンドウを閉じますか？"
        let cancelTitle = "編集を続ける", executeTitle = "ウィンドウを閉じる"
        AlertAppear(with: self).goBackHome(message: message, cancelTitle: cancelTitle, executeTitle: executeTitle)
    }
    @objc private func editBarButton() {
        newDataTableView.setEditing(true, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(editBarButtonDone))
    }
    @objc private func editBarButtonDone() {
        newDataTableView.setEditing(false, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editBarButton))
    }
    @objc private func keyboardWillShow(notification: Notification) {
        userInfo = (notification as NSNotification).userInfo
    }
    @objc private func keyboardDidHide() {
        userInfo = nil
    }
    private func settingUI() {
        [saveButton, addRowButton, randomSwitchButton].forEach { $0?.imageSet() }
        randomSwitchLabel.text = randomSwitchButton.flag ? "ON" : "OFF"
        presenter.setContents()
    }
    private func settingGesture() {
        saveButton.addTarget(self, action: #selector(saveCompleted), for: .touchUpInside)
        addRowButton.addTarget(self, action: #selector(addRowInsert), for: .touchUpInside)
        randomSwitchButton.addTarget(self, action: #selector(ratioRandom), for: .touchUpInside)
    }
    //     データの保存
    @objc private func saveCompleted() {
        presenter.saveContents()
    }
    //     行の挿入
    @objc private func addRowInsert() {
        let indexPath = IndexPath(row: 0, section: 0)
        presenter.addDataTemporary()
        newDataTableView.insertRows(at: [indexPath], with: .fade)
        newDataTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        newDataTableView.contentInset.bottom = newDataTableView.frame.height - newDataTableView.contentSize.height
    }
    //     ルーレットのグラフの比率をランダムにする。
    @objc private func ratioRandom() {
        randomSwitchButton.flag.toggle()
        randomSwitchLabel.text = randomSwitchButton.flag ? "ON" : "OFF"
        newDataTableView.reloadData()
    }
    //     テキストサイズをデバイスごとに再計算
    private func fontSizeRecalcForEachDevice() {
        [saveButton, addRowButton, randomSwitchButton].forEach { $0.fontSizeRecalcForEachDevice() }
        [saveLabel, addRowLabel, randomSwitchLabel].forEach { $0.fontSizeRecalcForEachDevice() }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //        keyboardが表示している時はinsetをkeyboardのframe、非表示の時はoperationViewのframe。
        //        keyboardが表示されている時でも最下のcellまでスクロールできるようにする。
        if userInfo != nil {
            let keyboardFrame = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey]as! NSValue).cgRectValue // keyboardの座標を取得
            newDataTableView.contentInset.bottom = keyboardFrame.size.height
        } else {
            newDataTableView.contentInset.bottom = operationView.frame.height // スクロールした時の停止位置を指定。セルがoperationViewに被らないようにする。
        }
    }
}
// MARK: - TableViewDelegate,Datasource
extension NewDataViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        numberOfRows
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)as! NewDataTableViewCell
        let temporary = graphTemporary(index: indexPath.row)
        cell.graphDataTemporary = temporary
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(80).recalcValue
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presenter.deleteRow(indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true // セルのドラッグ＆ドロップを有効
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        presenter.moveRow(sourceIndexPath, destinationIndexPath)
    }
}
extension NewDataViewController: NewDataOutput {
    // 保存しているデータをセット
    func setContents(dataSet: RouletteData) {
        titleTextField.text = dataSet.title
        titleTextField.overrideUserInterfaceStyle = .light
        randomSwitchButton.flag = dataSet.randomFlag
        colorIndex = dataSet.colorIndex
        stride(from: 0, to: 360, by: 18).forEach { i in
            let color = UIColor.hsvToRgb(h: Float(i), s: 128, v: 255)
            colors.append(color)
        }
    }
    // データ保存
    func saveContents(dataSet: RouletteData) {
        let title = titleTextField.text ?? ""
        let flag = randomSwitchButton.flag
        let save = SaveData(with: self, dataSet: dataSet)
        save.saveRouletteData(title: title, flag: flag, colorIndex: colorIndex)
    }
    // 先頭から行を追加していく
    func addRow() -> RouletteGraphTemporary {
        let row = RouletteGraphTemporary()
        let rgb = colors[colorIndex]
        row.rgbTemporary = ["r": rgb.r, "g": rgb.g, "b": rgb.b]
        colorIndex = colorIndex < colors.count - 1 ? colorIndex + 1 : 0
        return row
    }
}
// protocolを定義してpresenterのプロパティやメソッドを他のファイルでも使えるように
extension NewDataViewController: NewDataPresenterInput {
    var numberOfRows: Int { presenter.numberOfRows }
    func graphTemporary(index: Int) -> RouletteGraphTemporary {
        presenter.getGraphTemporary(index: index)
    }
}

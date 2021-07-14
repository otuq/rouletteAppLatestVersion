//
//  EditViewController.swift
//  roulette
//
//  Created by USER on 2021/06/21.
//

import UIKit
import RealmSwift

//カラーデータとテキストデータの受け渡し方
//カラーデータは datasetsが空ならaddRowInsertの初期値cyan→TableViewCell→ColorSelectVC→NewDataVCのdatasetsへ格納
//テキストデータは NewDataVCからtTableViewCellにアクセス→textFieldのtextをdatasetsに格納
class NewDataViewController: UIViewController {
    //MARK:-properties
    private let cellId = "cellId"
    var realm: Realm {
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
        addRowButton.setTitle("add", for: .normal)
        addRowButton.delegate = self
        return addRowButton
    }
    var dataSet = RouletteData()
    
    //MARK:-Outlets,Actions
    @IBOutlet weak var newDataTableView: UITableView!
    @IBOutlet weak var titleTextView: UITextField!
    @IBAction func doneButton(_ sender: Any) {
        guard let nav = presentingViewController as? UINavigationController,
              let homeVC = nav.topViewController as? HomeViewController else { return }
        view.endEditing(true)
        //titleのデータの更新
        try! realm.write({
            dataSet.title = titleTextView.text ?? ""
        })
        //cellの情報のデータの更新
        dataSet.temporarys.enumerated().forEach { (index, temporary) in
            let list = dataSet.list[index]
            try! realm.write({
                list.text = temporary.textTemporary
                list.r = temporary.rgbTemporary["r"]!
                list.g = temporary.rgbTemporary["g"]!
                list.b = temporary.rgbTemporary["b"]!
            })
        }
        //新規データの作成or更新
        if navigationController?.viewControllers.first is SetDataViewController{
            print("データを更新しました。")
            homeVC.dataSet = dataSet
            homeVC.rouletteTitleLabel.text = dataSet.title.isEmpty ? "No title": dataSet.title
            dismiss(animated: true, completion: nil)
        }else{
            print("データを新規作成しました。")
            homeVC.dataSet = dataSet
            try! realm.write({
                realm.add(dataSet)
            })
            homeVC.rouletteTitleLabel.text = dataSet.title.isEmpty ? "No title": dataSet.title
            dismiss(animated: true, completion: nil)
        }
    }
    
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
        newDataTableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        self.view.addSubview(addRowButton)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editRouletteSets))
    }
    @objc private func editRouletteSets() {
        newDataTableView.setEditing(true, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editRouletteSetsDone))
    }
    @objc private func editRouletteSetsDone() {
        newDataTableView.setEditing(false, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editRouletteSets))
    }
    private func settingUI(){
        titleTextView.text = dataSet.title
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
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            dataSet.temporarys.remove(at: indexPath.row)
            try! realm.write({
                dataSet.list.remove(at: indexPath.row)
            })
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

//MARK:-AddRowDelegate
extension NewDataViewController: AddRowDelegate {
    func addRowInsert() {
        let indexPath = IndexPath(row: 0, section: 0)
        let addRow = RouletteGraphTemporary()
        let addList = RouletteGraphData()
        //先頭から行を追加していく
        //Realmデータベースを追加する
        dataSet.temporarys.insert(addRow, at: 0)
        try! realm.write({
            dataSet.list.insert(addList, at: 0)
        })
        newDataTableView.insertRows(at: [indexPath], with: .fade)
        newDataTableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
}

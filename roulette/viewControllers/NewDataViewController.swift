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
    private var addRowButton: AddRowButton {
        let addRowButton = AddRowButton.shared
        let xPoint = view.center.x - addRowButton.bounds.width / 2
        let yPoint = view.frame.maxY - view.frame.maxY / 6
        addRowButton.frame.origin = CGPoint(x: xPoint, y: yPoint )
        addRowButton.setTitle("add", for: .normal)
        addRowButton.delegate = self
        return addRowButton
    }
    private var realm: Realm!
    var dataSet: RouletteData!
    
    //MARK:-Outlets,Actions
    @IBOutlet weak var newDataTableView: UITableView!
    @IBOutlet weak var titleTextView: UITextField!
    @IBAction func doneButton(_ sender: Any) {
        guard let nav = self.presentingViewController as? UINavigationController,
              let homeVC = nav.viewControllers[nav.viewControllers.count - 1]as? HomeViewController,
              let tb = newDataTableView.visibleCells as? [TableViewCell] else { return }
        tb.enumerated().forEach { (index,cell) in
            dataSet.rouletteData[index].text = cell.rouletteTextView.text ?? ""
        }
        dataSet.title = titleTextView.text ?? "No title"
        homeVC.dataSets = dataSet
        
        dismiss(animated: true, completion: nil)
    }
    
    //MARK:-LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        settingView()
    }
    private func settingView() {
        newDataTableView.delegate = self
        newDataTableView.dataSource = self
        newDataTableView.separatorStyle = .none
        newDataTableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        self.view.addSubview(addRowButton)
    }
}

//MARK:-TableViewDelegate,Datasource
extension NewDataViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSet.rouletteData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)as! TableViewCell
        cell.labelColor = dataSet.rouletteData[indexPath.row].color
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            dataSet.rouletteData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

//MARK:-AddRowDelegate
extension NewDataViewController: AddRowDelegate {
    func addRowInsert() {
        let indexPath = IndexPath(row: 0, section: 0)
        let addRow = RouletteGraphData()
        //先頭から行を追加していく
        dataSet.rouletteData.insert(addRow, at: 0)
        newDataTableView.insertRows(at: [indexPath], with: .fade)
        newDataTableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
}

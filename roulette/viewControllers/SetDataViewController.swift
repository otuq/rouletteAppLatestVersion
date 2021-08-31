//
//  SetDataViewController.swift
//  roulette
//
//  Created by USER on 2021/07/02.
//

import UIKit
import RealmSwift

class SetDataViewController: UIViewController {
    //MARK:-properties
    private let cellId = "cellId"
    private var realm = try! Realm()
    private var dataSets: Results<RouletteData> {
        let data = realm.objects(RouletteData.self)
        return data
    }
    
    //MARK:-Outlets,Actions
    @IBOutlet weak var setDataTableView: UITableView!
    
    //MARK:-Lifecyle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        settingView()
    }
    private func settingView() {
        setDataTableView.delegate = self
        setDataTableView.dataSource = self
        setDataTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editRouletteSets))
    }
    @objc private func editRouletteSets() {
        setDataTableView.setEditing(true, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editRouletteSetsDone))
    }
    @objc private func editRouletteSetsDone() {
        setDataTableView.setEditing(false, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editRouletteSets))
    }
}
//MARK:-TableViewDelegate,Datasource
extension SetDataViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSets.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let graphTitle = dataSets[indexPath.row].title
        cell.textLabel?.text = graphTitle.isEmpty ? "No title" : graphTitle
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "NewData", bundle: nil)
        if let newDataVC = storyboard.instantiateViewController(withIdentifier: "NewDataViewController")as? NewDataViewController {
            //選択したグラフデータのインデックスとrgb情報を
            let dataSet = dataSets[indexPath.row]
//            dataSet.index = indexPath.row
            dataSet.list.forEach { list in
                let temporary = RouletteGraphTemporary()
                temporary.textTemporary = list.text
                temporary.rgbTemporary["r"] = list.r
                temporary.rgbTemporary["g"] = list.g
                temporary.rgbTemporary["b"] = list.b
                temporary.ratioTemporary = list.ratio
                dataSet.temporarys.append(temporary)
            }
            newDataVC.dataSet = dataSet
            navigationController?.pushViewController(newDataVC, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //データベースからルーレット情報を削除する。
            try! realm.write {
                realm.delete(dataSets[indexPath.row])
                setDataTableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
}

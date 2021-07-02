//
//  SetDataViewController.swift
//  roulette
//
//  Created by USER on 2021/07/02.
//

import UIKit

class SetDataViewController: UIViewController {

    //MARK:-properties
    private let cellId = "cellId"
    var dataSets = [String]()
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
    }
}

extension SetDataViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = dataSets[indexPath.row]
        cell.detailTextLabel?.text = dataSets[indexPath.row]
        return cell
    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        <#code#>
//    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}

//
//  SetDataViewController.swift
//  roulette
//
//  Created by USER on 2021/07/02.
//

import UIKit

class SetDataViewController: UIViewController {
    // MARK: - properties
    private let cellId = "cellId"
    private let presenter = SetDataPresenter()
    
    // MARK: - Outlets,Actions
    @IBOutlet var setDataTableView: UITableView!
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        statusBarStyleChange(style: .lightContent)
        settingView()
        settingGesture()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = setDataTableView.indexPathForSelectedRow {
            UIView.animate(withDuration: 1) {
                self.setDataTableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    private func settingView() {
        setDataTableView.delegate = self
        setDataTableView.dataSource = self
        setDataTableView.register(SetDataTableViewCell.self, forCellReuseIdentifier: cellId)
    }
    private func settingGesture() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelBarButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editBarButton))
    }
    @objc private func cancelBarButton() {
        guard let nav = self.presentingViewController as? UINavigationController,
              let rootVC = nav.viewControllers.first as? HomeViewController else { return }
        rootVC.setDataButton.isSelected = false
        statusBarStyleChange(style: .darkContent)
        dismiss(animated: true, completion: nil)
    }
    @objc private func editBarButton() {
        setDataTableView.setEditing(true, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(editBarButtonDone))
    }
    @objc private func editBarButtonDone() {
        setDataTableView.setEditing(false, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editBarButton))
    }
}
// MARK: - TableViewDelegate,Datasource
extension SetDataViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRows
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)as! SetDataTableViewCell
        cell.dataset = presenter.getDatas(indexPath: indexPath)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.newDataVCTransition(indexPath: indexPath) { vc in
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(80).recalcValue
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // データベースからルーレット情報を削除する。
            presenter.deleteData(indexPath: indexPath) {
                AlertAppear(with: self).cancel()
            } completion: {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
}

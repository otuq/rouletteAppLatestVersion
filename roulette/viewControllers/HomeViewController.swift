//
//  HomeViewController.swift
//  roulette
//
//  Created by USER on 2021/06/21.
//

import UIKit

class HomeViewController: UIViewController {
    //MARK:- Properties
    var setDataLabel: UILabel {
        let label = UILabel()
        label.frame = CGRect(origin: .zero, size: CGSize(width: 200, height: 20))
        label.center = view.center
        label.textAlignment = .center
        label.text = "TAP Roulette Set"
        label.font = UIFont.systemFont(ofSize: 16, weight: .light)
        UIView.transition(with: label, duration: 2.0, options: [.transitionCrossDissolve, .autoreverse, .repeat], animations: {
            label.layer.opacity = 0
        }) { _ in
            label.layer.opacity = 1
            label.text = "T A P"
        }
        return label
    }
    var dataSet: RouletteData?
    var parentLayer = CALayer()
    //MARK:-Outlets,Actions
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var setDataButton: UIButton!
    @IBOutlet weak var newDataButton: UIButton!
    @IBOutlet weak var rouletteTitleLabel: UILabel!
    @IBAction func appSettingButton(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "AppSetting", bundle: nil)
        let viewcontroller = storyboard.instantiateViewController(withIdentifier: "AppSettingViewController")
        let nav = UINavigationController.init(rootViewController: viewcontroller)
        nav.modalPresentationStyle = .overFullScreen
        present(nav, animated: true, completion: nil)
    }
    
    //MARK:-Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        settingGesture()
        settingAccesory()
        
    }
    private func settingGesture() {
        let startGesture = UITapGestureRecognizer(target: self, action: #selector(startGesture))
        let setGesture = UITapGestureRecognizer(target: self, action: #selector(setGesture))
        let newGesture = UITapGestureRecognizer(target: self, action: #selector(newGesture))
        let editGesture = UITapGestureRecognizer(target: self, action: #selector(editGesture))
        
        startButton.addGestureRecognizer(startGesture)
        setDataButton.addGestureRecognizer(setGesture)
        newDataButton.addGestureRecognizer(newGesture)
        rouletteTitleLabel.addGestureRecognizer(editGesture)
        navigationController?.isNavigationBarHidden = true
    }
    @objc private func startGesture() {
        if dataSet != nil {
            let storyboard = UIStoryboard(name: "Roulette", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "RouletteViewController")
            let nav = UINavigationController(rootViewController: viewController)
            nav.modalPresentationStyle = .overFullScreen
            nav.modalTransitionStyle = .crossDissolve
            present(nav, animated: true, completion: nil)
        }
    }
    @objc private func setGesture() {
        let storyboard = UIStoryboard.init(name: "SetData", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "SetDataViewController")
        let nav = UINavigationController.init(rootViewController: viewController)
        nav.modalPresentationStyle = .overFullScreen
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        setDataButton.isSelected = true
        present(nav, animated: true, completion: nil)
    }
    @objc private func newGesture() {
        let storyboard = UIStoryboard.init(name: "NewData", bundle: nil)
        let newVC = storyboard.instantiateViewController(withIdentifier: "NewDataViewController")
        let nav = UINavigationController.init(rootViewController: newVC)
        newVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        nav.modalPresentationStyle = .overFullScreen
        //newButtonの選択状態で新規か更新の分岐をする
        newDataButton.isSelected = true
        present(nav, animated: true, completion: nil)
    }
    @objc private func editGesture() {
        if let dataSet = dataSet {
            let storyboard = UIStoryboard.init(name: "NewData", bundle: nil)
            guard let newVC = storyboard.instantiateViewController(withIdentifier: "NewDataViewController")as? NewDataViewController else { return }
            let nav = UINavigationController.init(rootViewController: newVC)
            //listに保存されたデータをtemporaryに代入しないとcancelしても前のセルが上書きされる。
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
            newVC.dataSet = dataSet
            print(dataSet.temporarys.count)
            newVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
            nav.modalPresentationStyle = .overFullScreen
            present(nav, animated: true, completion: nil)
        }
    }
    @objc private func cancel() {
        newDataButton.isSelected = false
        setDataButton.isSelected = false
        dismiss(animated: true, completion: nil)
    }
    func settingAccesory() {
        startButton.accesory()
    }
}



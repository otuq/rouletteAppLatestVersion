//
//  HomeViewController.swift
//  roulette
//
//  Created by USER on 2021/06/21.
//

import UIKit

protocol StatusBarStyleChangeDelegate {
    func statusBarStyleChange(style: UIStatusBarStyle)
}

class HomeViewController: UIViewController {
    //MARK:- Properties
    var statusBarStyleChange: UIStatusBarStyle = .darkContent
    var setDataLabel: UILabel {
        let label = UILabel()
        label.frame = CGRect(origin: .zero, size: CGSize(width: 200, height: 20))
        label.center = view.center
        label.textAlignment = .center
        label.baselineAdjustment = .alignCenters
        label.text = "T A P"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor.init(r: 153, g: 153, b: 153)
        UIView.transition(with: label, duration: 1.0, options: [.transitionCrossDissolve, .autoreverse, .repeat], animations: {
            label.layer.opacity = 0
        }) { _ in
            label.layer.opacity = 1
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
    @IBOutlet weak var appSettingButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    //MARK:-Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        settingGesture()
        settingAccesory()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        print("okkk")
//        if let presented = presentedViewController {
//            print("ok")
//            if type(of: presented) == UINavigationController.self {
//                statusBarStyleChange = .darkContent
//                setNeedsStatusBarAppearanceUpdate()
//            }
//        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyleChange
    }
    private func settingGesture() {
        let editGesture = UITapGestureRecognizer(target: self, action: #selector(editGesture))
        startButton.addTarget(self, action: #selector(startGesture), for: .touchUpInside)
        setDataButton.addTarget(self, action: #selector(setGesture), for: .touchUpInside)
        newDataButton.addTarget(self, action: #selector(newGesture), for: .touchUpInside)
        appSettingButton.addTarget(self, action: #selector(appSettingGesture), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareGesture), for: .touchUpInside)
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
    @objc private func appSettingGesture() {
        let storyboard = UIStoryboard.init(name: "AppSetting", bundle: nil)
        let viewcontroller = storyboard.instantiateViewController(withIdentifier: "AppSettingViewController")
        let nav = UINavigationController.init(rootViewController: viewcontroller)
        nav.modalPresentationStyle = .overFullScreen
        present(nav, animated: true, completion: nil)
    }
    @objc private func shareGesture() {
        let text = "ぺぺぺぺぺ"
        let items = [text]
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    func settingAccesory() {
        startButton.homeButtonDecoration()
        newDataButton.homeButtonDecoration()
        setDataButton.homeButtonDecoration()
        appSettingButton.homeButtonDecoration()
        shareButton.homeButtonDecoration()
    }
}
//extension HomeViewController: StatusBarStyleChangeDelegate {
//    func statusBarStyleChange(style: UIStatusBarStyle) {
//        statusBarStyleChange = style
//        setNeedsStatusBarAppearanceUpdate()
//        print("ok")
//    }
//}

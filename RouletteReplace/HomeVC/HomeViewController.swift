//
//  HomeViewController.swift
//  roulette
//
//  Created by USER on 2021/06/21.
//

import UIKit

protocol HomeOutput: AnyObject {
    func setTitle(dataSet: RouletteData)
    func rouletteVCTransition()
    func newDataVCTransition()
    func setDataVCTranstion()
    func editDataVCTransition()
    func appSettingVCTransition()
    func shareVCTransition()
}
protocol HomeToNewDataOutput: AnyObject {
    // newDataButtonのisSelectedの状態を渡す
    var selected: Bool { get }
}
class HomeViewController: UIViewController {
    // MARK: Properties
    private var presenter: HomeInput!
    var statusBarStyleChange: UIStatusBarStyle = .darkContent
    
    // MARK: Outlets,Actions
    @IBOutlet var startButton: UIButton!
    @IBOutlet var setDataButton: UIButton!
    @IBOutlet var newDataButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var appSettingButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        initialize()
        settingUI()
        settingGesture()
    }
    func initialize() {
        presenter = HomePresenter(with: self)
        presenter.setTitle()
    }
    // ステータスバーのスタイルを変更
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyleChange
    }
    private func settingUI() {
        let arrays = [startButton, newDataButton, setDataButton, appSettingButton, shareButton]
        arrays.forEach { $0?.imageSet() }
        // テキストサイズをデバイスごとに再計算する
        arrays.forEach { $0?.fontSizeRecalcForEachDevice() }
    }
    private func settingGesture() {
        startButton.addTarget(self, action: #selector(startGesture), for: .touchUpInside)
        setDataButton.addTarget(self, action: #selector(setGesture), for: .touchUpInside)
        newDataButton.addTarget(self, action: #selector(newGesture), for: .touchUpInside)
        appSettingButton.addTarget(self, action: #selector(appSettingGesture), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareGesture), for: .touchUpInside)
        
        let editGesture = UITapGestureRecognizer(target: self, action: #selector(editGesture))
        titleLabel.addGestureRecognizer(editGesture)
    }
    @objc private func startGesture() {
        presenter.rouletteVCTransition()
    }
    @objc private func setGesture() {
        presenter.setVCTranstion()
    }
    @objc private func newGesture() {
        presenter.newDataVCTransition()
    }
    @objc private func editGesture() {
        presenter.editVCTransition()
    }
    @objc private func appSettingGesture() {
        presenter.appSettingVCTransition()
    }
    @objc private func shareGesture() {
        presenter.shareVCTransition()
    }
    func addStartLabel() {
        let label = StartLabel.shared.create()
        startButton.titleLabel?.removeFromSuperview()
        label.center = view.center
        newDataButton.isSelected = false
        setDataButton.isSelected = false
        view.addSubview(label)
        statusBarStyleChange(style: .darkContent)
    }
}
extension HomeViewController: HomeOutput {
    func setTitle(dataSet: RouletteData) {
        titleLabel.text = dataSet.title.isEmpty ? "No title": dataSet.title
        addStartLabel()
    }
    func rouletteVCTransition() {
        let vc = R.storyboard.roulette.rouletteViewController()
        Transition.shared.modalPresent(parentVC: self, presentingVC: vc, presentation: .overFullScreen, transition: .crossDissolve)
    }
    func newDataVCTransition() {
        let vc = R.storyboard.newData.newDataViewController()
        newDataButton.isSelected = true
        Transition.shared.modalPresent(parentVC: self, presentingVC: vc, presentation: .overFullScreen)
    }
    func setDataVCTranstion() {
        let vc = R.storyboard.setData.setDataViewController()
        setDataButton.isSelected = true
        Transition.shared.modalPresent(parentVC: self, presentingVC: vc, presentation: .overFullScreen)
    }
    func editDataVCTransition() {
        let vc = R.storyboard.newData.newDataViewController()
        Transition.shared.modalPresent(parentVC: self, presentingVC: vc, presentation: .overFullScreen)
    }
    func appSettingVCTransition() {
        let vc = R.storyboard.appSetting.appSettingViewController()
        Transition.shared.modalPresent(parentVC: self, presentingVC: vc, presentation: .overFullScreen)
    }
    func shareVCTransition() {
        let vc = ShareViewController.shared.create()
        Transition.shared.modalPresent(parentVC: self, presentingVC: vc)
    }
}
extension HomeViewController: HomeToNewDataOutput {
    var selected: Bool {
        newDataButton.isSelected
    }
}

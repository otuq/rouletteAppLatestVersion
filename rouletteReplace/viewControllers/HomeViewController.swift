//
//  HomeViewController.swift
//  roulette
//
//  Created by USER on 2021/06/21.
//

import RealmSwift
import UIKit

protocol HomeOutput: AnyObject {
    var dataPresent: RouletteData? { get }
    func newDataSelectedTrue()
    func setDataSelectedTrue()
    func addStartLabel(label: UILabel)
}
extension HomeViewController: HomeOutput {
    var dataPresent: RouletteData? { self.dataSet }
    func newDataSelectedTrue() {
        newDataButton.isSelected = true
    }
    func setDataSelectedTrue() {
        setDataButton.isSelected = true
    }
    func addStartLabel(label: UILabel) {
        if let dataSet = dataSet {
            titleLabel.text = dataSet.title.isEmpty ? "No title": dataSet.title
            startButton.titleLabel?.removeFromSuperview()
            label.center = view.center
            view.addSubview(label)
        }
    }
}
class HomeViewController: UIViewController {
    // MARK: Properties
    private var excuteOnce = {}
    typealias ExcuteOnce = () -> Void
    private var realm = try! Realm()
    private var presenter: HomeInput!
    
    var dataSet: RouletteData?
    var parentLayer = CALayer()
    var statusBarStyleChange: UIStatusBarStyle = .darkContent
    var startLabel = UILabel() // Save.swift
    
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
        excuteOnce()
        initialize()
        settingUI()
        settingGesture()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        excuteOnce = justOnceMethod {
            // 最後にセットしていたデータを取得
            let object = self.realm.objects(RouletteData.self).sorted(byKeyPath: "lastDate", ascending: true)
            self.dataSet = object.last
        }
    }
    // 起動時にのみ実行
    private func justOnceMethod(excute: @escaping () -> Void ) -> ExcuteOnce {
        var once = true
        return {
            if once { once = false; excute() }
        }
    }
    private func initialize() {
        presenter = HomePresenter(with: self)
    }
    // ステータスバーのスタイルを変更
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyleChange
    }
    private func settingUI() {
        let arrays = [startButton, newDataButton, setDataButton, appSettingButton, shareButton]
        arrays.forEach{ $0?.imageSet() }
        // テキストサイズをデバイスごとに再計算する
        arrays.forEach{ $0?.fontSizeRecalcForEachDevice() }
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
        // 初期起動時データが空なのでデータがない時はSedDataVCに遷移しない。
        if realm.objects(RouletteData.self).isEmpty { return }
        presenter.setVCTranstion()
    }
    @objc private func newGesture() {
        presenter.newVCTranstion()
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
}

//
//  HomeViewController.swift
//  roulette
//
//  Created by USER on 2021/06/21.
//

import RealmSwift
import UIKit

class HomeViewController: UIViewController {
    // MARK: Properties
    private var excuteOnce = {}
    typealias ExcuteOnce = () -> Void
    private var realm = try! Realm()
    var dataSet: RouletteData?
    var parentLayer = CALayer()
    var statusBarStyleChange: UIStatusBarStyle = .darkContent
    var startLabel = UILabel()

    // MARK: Outlets,Actions
    @IBOutlet var startButton: UIButton!
    @IBOutlet var setDataButton: UIButton!
    @IBOutlet var newDataButton: UIButton!
    @IBOutlet var rouletteTitleLabel: UILabel!
    @IBOutlet var appSettingButton: UIButton!
    @IBOutlet var shareButton: UIButton!

    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        excuteOnce()
        settingUI()
        settingGesture()
        fontSizeRecalcForEachDevice()
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
            if once {
                once = false
                excute()
            }
        }
    }
    // ステータスバーのスタイルを変更
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyleChange
    }
    private func settingUI() {
        startButton.imageSet()
        newDataButton.imageSet()
        setDataButton.imageSet()
        appSettingButton.imageSet()
        shareButton.imageSet()
        startLabel = self.createStartLabel()

        if let dataSet = self.dataSet {
            self.rouletteTitleLabel.text = dataSet.title.isEmpty ? "No title": dataSet.title
            self.startButton.titleLabel?.removeFromSuperview()
            self.view.addSubview(startLabel)
        }
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
        if let dataSet = dataSet {
            let storyboard = UIStoryboard(name: "Roulette", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "RouletteViewController")as! RouletteViewController
//            viewController.rouletteDataSet = (dataSet, dataSet.list)

            let nav = UINavigationController(rootViewController: viewController)
            nav.modalPresentationStyle = .overFullScreen
            nav.modalTransitionStyle = .crossDissolve
            present(nav, animated: true, completion: nil)
        }
    }
    @objc private func setGesture() {
        // 初期起動時データが空なのでデータがない時はSedDataVCに遷移しない。
        if realm.objects(RouletteData.self).isEmpty { return }

        let storyboard = UIStoryboard(name: "SetData", bundle: nil)
        let setDataVC = storyboard.instantiateViewController(withIdentifier: "SetDataViewController")as! SetDataViewController
        let nav = UINavigationController(rootViewController: setDataVC)
        nav.modalPresentationStyle = .overFullScreen
        setDataVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        setDataButton.isSelected = true
        present(nav, animated: true, completion: nil)
    }
    @objc private func newGesture() {
        let storyboard = UIStoryboard(name: "NewData", bundle: nil)
        let newVC = storyboard.instantiateViewController(withIdentifier: "NewDataViewController")
        let nav = UINavigationController(rootViewController: newVC)
        newVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        nav.modalPresentationStyle = .overFullScreen
        // newButtonの選択状態で新規か更新の分岐をする
        newDataButton.isSelected = true
        present(nav, animated: true, completion: nil)
    }
    @objc private func editGesture() {
        if let dataSet = dataSet {
            let storyboard = UIStoryboard(name: "NewData", bundle: nil)
            guard let newVC = storyboard.instantiateViewController(withIdentifier: "NewDataViewController")as? NewDataViewController else { return }
            let nav = UINavigationController(rootViewController: newVC)
            // listに保存されたデータをtemporaryに代入しないとcancelしても前のセルが上書きされる。
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
        let storyboard = UIStoryboard(name: "AppSetting", bundle: nil)
        let viewcontroller = storyboard.instantiateViewController(withIdentifier: "AppSettingViewController")
        let nav = UINavigationController(rootViewController: viewcontroller)
        nav.modalPresentationStyle = .overFullScreen
        present(nav, animated: true, completion: nil)
    }
    @objc private func shareGesture() {
        let textString = "友人や家族にこのアプリを紹介しよう♪"
//        let urlString = "https://apps.apple.com/jp/app/thee-roulette/id1602651709"
        let items = [textString, "URLないのよ〜"]
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)

        present(activityVC, animated: true, completion: nil)
    }
    private func createStartLabel() -> UILabel {
        let label = UILabel()
        label.frame = CGRect(origin: .zero, size: CGSize(width: 200, height: 20))
        label.center = view.center
        label.textAlignment = .center
        label.baselineAdjustment = .alignCenters
        label.text = "T A P"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(r: 153, g: 153, b: 153)
        label.fontSizeRecalcForEachDevice()
        UIView.transition(with: label, duration: 1.0, options: [.transitionCrossDissolve, .autoreverse, .repeat], animations: {
            label.layer.opacity = 0
        }, completion: { _ in
            label.layer.opacity = 1
        })
        return label
    }
    // テキストサイズをデバイスごとに再計算する
    private func fontSizeRecalcForEachDevice() {
        startButton.fontSizeRecalcForEachDevice()
        newDataButton.fontSizeRecalcForEachDevice()
        setDataButton.fontSizeRecalcForEachDevice()
        rouletteTitleLabel.fontSizeRecalcForEachDevice()
        appSettingButton.fontSizeRecalcForEachDevice()
        shareButton.fontSizeRecalcForEachDevice()
    }
}

//
//  HomeViewController.swift
//  roulette
//
//  Created by USER on 2021/06/21.
//

import UIKit
import RealmSwift
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport

class HomeViewController: UIViewController {
    //MARK: -Properties
    private var excuteOnce = {}
    typealias ExcuteOnce = () -> ()
    private var realm = try! Realm()
    var dataSet: RouletteData?
    var parentLayer = CALayer()
    var statusBarStyleChange: UIStatusBarStyle = .darkContent
    var startLabel = UILabel()
    
    //MARK: -Outlets,Actions
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var setDataButton: UIButton!
    @IBOutlet weak var newDataButton: UIButton!
    @IBOutlet weak var rouletteTitleLabel: UILabel!
    @IBOutlet weak var appSettingButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    var bannerView: GADBannerView!
    
    //MARK: -Lifecycle Methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        adUnitId()
    }
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
            let object = self.realm.objects(RouletteData.self).sorted(byKeyPath: "lastDate", ascending: true)
            self.dataSet = object.last
        }
    }
    private func justOnceMethod(excute: @escaping () -> () ) -> ExcuteOnce {
        var once = true
        return {
            if once {
                once = false
                excute()
            }
        }
    }
    //ステータスバーのスタイルを変更
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
            viewController.rouletteDataSet = (dataSet, dataSet.list)
            let nav = UINavigationController(rootViewController: viewController)
            nav.modalPresentationStyle = .overFullScreen
            nav.modalTransitionStyle = .crossDissolve
            present(nav, animated: true, completion: nil)
        }
    }
    @objc private func setGesture() {
        //初期起動時データが空なのでデータがない時はSedDataVCに遷移しない。
        if realm.objects(RouletteData.self).isEmpty { return }
        
        let storyboard = UIStoryboard.init(name: "SetData", bundle: nil)
        let setDataVC = storyboard.instantiateViewController(withIdentifier: "SetDataViewController")as! SetDataViewController
        let nav = UINavigationController.init(rootViewController: setDataVC)
        nav.modalPresentationStyle = .overFullScreen
        setDataVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
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
        let text = ""
        let items = [text]
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
        label.textColor = UIColor.init(r: 153, g: 153, b: 153)
        label.fontSizeRecalcForEachDevice()
        UIView.transition(with: label, duration: 1.0, options: [.transitionCrossDissolve, .autoreverse, .repeat], animations: {
            label.layer.opacity = 0
        }) { _ in
            label.layer.opacity = 1
        }
        return label
    }
    private func fontSizeRecalcForEachDevice() {
        startButton.fontSizeRecalcForEachDevice()
        newDataButton.fontSizeRecalcForEachDevice()
        setDataButton.fontSizeRecalcForEachDevice()
        rouletteTitleLabel.fontSizeRecalcForEachDevice()
        appSettingButton.fontSizeRecalcForEachDevice()
        shareButton.fontSizeRecalcForEachDevice()
    }
}
//MARK: GoogleADs
extension HomeViewController: GADBannerViewDelegate {
    //広告IDの設定
    private func adUnitId() {
        guard let adUnitID = Bundle.main.object(forInfoDictionaryKey: "AdUnitID")as? [String: String],
              let bannerID = adUnitID["banner"] else { return }
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        [bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
         bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)].forEach{$0.isActive = true}
        bannerView.adUnitID = bannerID
        bannerView.rootViewController = self
        bannerView.delegate = self
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        //IDFAを取得してから広告を読み込む。
        //トラッキングアラートの表示はタイミングを間違えると表示されずに拒否されてしまうのでメインキューに追加して最後に実行されるようにする。
        DispatchQueue.main.async {
            self.getIDFAAndRequest()
        }
    }
    //IDFAの取得
    private func getIDFAAndRequest() {
        if #available(iOS 14, *) {
            switch ATTrackingManager.trackingAuthorizationStatus {
            case .authorized:
                print("authorized 許可されました")
                print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
                self.bannerView.load(GADRequest()); print("広告がリクエストされました")
            case .denied:
                print("denied 拒否されました")
                self.bannerView.load(GADRequest()); print("広告がリクエストされました")
            case .restricted:
                print("restriced 制限されました")
                self.bannerView.load(GADRequest()); print("広告がリクエストされました")
            case .notDetermined:
                print("not determind まだ決まってません")
                self.trackingAuthorizationAlert()
            @unknown default:
                fatalError()
            }
        }else{
            self.bannerView.load(GADRequest()); print("広告がリクエストされました")
        }
    }
    //トラッキングのアラートを表示
    private func trackingAuthorizationAlert() {
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
            switch status {
            case .authorized:
                print("authorized 許可されました")
                print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
            case .denied, .restricted, .notDetermined:
                print("not authorized")
            @unknown default:
                fatalError()
            }
            self.bannerView.load(GADRequest()); print("広告がリクエストされました")
        })
    }
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
    }
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("広告のリクエストに失敗　bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("広告のリクエストに成功　bannerViewDidRecordImpression")
        
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("広告を開きます　bannerViewWillPresentScreen")
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("広告を閉じます　bannerViewWillDIsmissScreen")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("広告を閉じました　bannerViewDidDismissScreen")
    }
}

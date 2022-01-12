//
//  RouletteViewController.swift
//  roulette
//
//  Created by USER on 2021/06/15.
//

import UIKit
import AVFoundation
import RealmSwift
import GoogleMobileAds

class RouletteViewController: UIViewController {
    //MARK: -Properties
    private let userDefaults = UserDefaults.standard
    private let parentLayer = CALayer() //ここに各グラフを統合する
    private let frameLayer = CALayer() //ここに各グラフごとの境界線を統合する。
    private let rouletteView = UIView() //parentLayerをセットする。
    private let around = CGFloat.pi * 2 //360度 1回転
    private let dtStop = CGFloat.random(in: 0...CGFloat.pi * 2) //止まる角度
    private let duration: TimeInterval = 10 //回る時間(秒)
    private let objectWidth: CGFloat = CGFloat(30).recalcValue
    private var audioPlayer: AVAudioPlayer!
    private var startTime: CFTimeInterval! //アニメーション開始時間
    private var startRatio = 0.0 //グラフの描画開始点に使う
    private var graphRange = [ClosedRange<Double>]() //各グラフの範囲
    private var interstitial: GADInterstitialAd? //インタースティシャル広告
    private let diameter: CGFloat = {
        let width = UIScreen.main.bounds.width
        let subtraction = (width / 13) / 2
        return (width - subtraction)
    }() //直径
    var rouletteDataSet: (dataSet: RouletteData, list: List<RouletteGraphData>)!
    
    //MARK: -Outlets,Actions
    @IBOutlet var tapStartLabel: [UILabel]!
    @IBOutlet weak var quitButton: UIButton!
    
    //MARK: -Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        createGraph()
        settingUI()
        settingView()
        settingGesture()
        createInterstitial()
        fontSizeRecalcForEachDevice()
        blinkAnimation(labels: tapStartLabel)
    }
    private func settingUI() {
        quitButton.imageSet()
        quitButton.fontSizeRecalcForEachDevice()
    }
    private func settingView() {
        let pointerImageView = UIImageView(image: roulettePointerImage(w: objectWidth))
        let centerCircleLabel = rouletteCenterCircleLabel(w: objectWidth)
        let frameCircleView = rouletteFrameCircle(w: diameter)
        pointerImageView.center = CGPoint(x: view.center.x, y: (view.center.y - diameter / 2) - (objectWidth / 2) + 5 )
        centerCircleLabel.center = view.center
        frameCircleView.center = view.center
        
        rouletteView.frame = view.frame
        rouletteView.backgroundColor = .clear
        
        view.addSubview(rouletteView)
        view.addSubview(pointerImageView)
        view.addSubview(centerCircleLabel)
        view.addSubview(frameCircleView)
        view.sendSubviewToBack(rouletteView)
        view.bringSubviewToFront(pointerImageView)
        navigationController?.isNavigationBarHidden = true
    }
    private func settingGesture() {
        let startTapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapStart))
        view.addGestureRecognizer(startTapGesture)
        quitButton.addTarget(self, action: #selector(quitTapDismiss), for: .touchUpInside)
    }
    //インタースティシャル広告を読み込む
    private func createInterstitial() {
        guard let adUnitID = Bundle.main.object(forInfoDictionaryKey: "AdUnitID")as? [String: String],
              let interstitialID = adUnitID["interstitial"] else { return }
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: interstitialID,
                               request: request,
                               completionHandler: { [self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            interstitial = ad
            interstitial?.fullScreenContentDelegate = self
        }
        )
    }

    //デバイス毎にUIのテキストサイズを再計算
    private func fontSizeRecalcForEachDevice() {
        tapStartLabel.forEach { $0.fontSizeRecalcForEachDevice() }
        quitButton.fontSizeRecalcForEachDevice()
    }
    //ルーレットを中止
    @objc private func quitTapDismiss() {
        let alertVC = UIAlertController(title: .none, message: "ルーレットを中止しますか？", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        let action = UIAlertAction(title: "中止する", style: .default) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        alertVC.addAction(cancel)
        alertVC.addAction(action)
        present(alertVC, animated: true, completion: nil)
    }
    //ルーレットを開始
    @objc private func viewTapStart(tapGesture: UITapGestureRecognizer) {
        tapStartLabel.forEach { label in
            label.isHidden = true
        }
        quitButton.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.rotateAnimation()
            self.rouletteSoundSetting()
        }
        view.removeGestureRecognizer(tapGesture)
    }
    //テキストの点滅
    private func blinkAnimation(labels: [UILabel]) {
        labels.forEach { label in
            UIView.transition(with: label, duration: 1.0, options: [.transitionCrossDissolve, .autoreverse, .repeat], animations: {
                label.layer.opacity = 0
            }) { _ in
                label.layer.opacity = 1
            }
        }
    }
    //ルーレットの針
    private func roulettePointerImage(w: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: w, height: w))
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: w, y: 0))
        path.addLine(to: CGPoint(x: w / 2, y: w))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.close()
        UIColor.red.setFill()
        path.fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    //ルーレットの真ん中のオブジェクト
    private func rouletteCenterCircleLabel(w: CGFloat) -> UILabel {
        let circleLabel = UILabel()
        circleLabel.bounds.size = CGSize(width: w, height: w)
        circleLabel.decoration(bgColor: .white)
        return circleLabel
    }
    //ルーレットの外側円線
    private func rouletteFrameCircle(w: CGFloat) -> UIView {
        let frameCircleView = UIView()
        frameCircleView.bounds.size = CGSize(width: w, height: w)
        frameCircleView.backgroundColor = .clear
        frameCircleView.layer.cornerRadius = frameCircleView.bounds.width / 2
        frameCircleView.layer.borderWidth = 2
        frameCircleView.layer.masksToBounds = true
        return frameCircleView
    }
    //ルーレットの音楽
    private func rouletteSoundSetting() {
        let dataSet = rouletteDataSet.dataSet
        guard let soundAsset  = NSDataAsset(name: dataSet.sound) else {
            print("not found")
            return
        }
        do{
            audioPlayer = try AVAudioPlayer(data: soundAsset.data, fileTypeHint: "wav")
            audioPlayer.prepareToPlay()
            audioPlayer.numberOfLoops = -1
            audioPlayer.play()
        }catch{
            print(error.localizedDescription)
            audioPlayer = nil
        }
    }
}
//MARK: -CreateGraph
extension RouletteViewController {
    
    //円弧形グラフのパス
    private func graphPath(radius: CGFloat, startAngle: Double, endAngle: Double) -> UIBezierPath{
        let path = UIBezierPath(
            arcCenter: .zero,
            radius: radius,
            startAngle: CGFloat(2 * Double.pi * startAngle / Double(around) - Double.pi / 2),
            endAngle: CGFloat(2 * Double.pi * endAngle / Double(around) - Double.pi / 2),
            clockwise: true
        )
        path.apply(CGAffineTransform(translationX: view.center.x, y: view.center.y))
        return path
    }
    //円弧形グラフごとの境界線
    private func graphFrameBoarder(startRatio: Double) {
        let path = UIBezierPath()
        let layer = CAShapeLayer()
        let angle = CGFloat(2 * Double.pi * startRatio / Double(around) - Double.pi / 2)
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: (diameter / 2) - 3, y: 0))
        path.apply(CGAffineTransform(rotationAngle: angle))
        path.apply(CGAffineTransform(translationX: view.center.x, y: view.center.y))
        layer.path = path.cgPath
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 3
        frameLayer.addSublayer(layer)
    }
    //円グラフの内側円線
    private func graphFrameCircleBoarder() {
        let path = UIBezierPath()
        let layer = CAShapeLayer()
        path.addArc(withCenter: .zero, radius: (diameter / 2) - 3, startAngle: 0, endAngle: around, clockwise: true)
        path.apply(CGAffineTransform(translationX: view.center.x, y: view.center.y))
        layer.fillColor = UIColor.clear.cgColor
        layer.path = path.cgPath
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 3
        frameLayer.addSublayer(layer)
    }
    //パスを元にイメージレイヤーを作成し、カウント分のレイヤーを親レイヤーに追加していく。
    private func drawGraph(fillColor: CGColor, _ startRatio: Double, _ endRatio: Double) {
        let circlePath = graphPath(radius: diameter / 4, startAngle: startRatio, endAngle: endRatio)
        let layer = CAShapeLayer()
        layer.path = circlePath.cgPath
        layer.lineWidth = diameter / 2
        layer.lineCap = .butt
        layer.strokeColor = fillColor
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeStart = 0
        layer.strokeEnd = 1
        //親レイヤーに描画するレイヤーを追加していく
        parentLayer.addSublayer(layer)
    }
    //グラフの幅の数値の合計を100/合計値で比率を算出する。
    private func drawRatios() -> [Double] {
        let dataSet = rouletteDataSet.dataSet
        let list = rouletteDataSet.list
        var ratios = [CGFloat]()
        for i in list{
            let randomValue = CGFloat.random(in: 1...10)
            let sliderValue = CGFloat(i.ratio)
            let ratio = dataSet.randomFlag ? randomValue : sliderValue
            ratios.append(ratio)
        }
        let totalValue = ratios.reduce(0){$0 + $1}
        let totalRatio = around / totalValue
        return ratios.map{Double($0 * totalRatio)}
    }
    //viewControllerにグラフを追加
    private func createGraph(){
        let dataSet = rouletteDataSet.dataSet
        let list = rouletteDataSet.list
        let drawRatios = drawRatios()
        drawRatios.enumerated().forEach { (index,ratio) in
            let graphData = list[index]
            let color = UIColor.init(r: graphData.r, g: graphData.g, b: graphData.b).cgColor
            let textString = graphData.text
            let textColor = dataSet.textColor
            let endRatio = startRatio + ratio
            let range = startRatio...endRatio
            let textAngleRatio = startRatio + (ratio / 2) //2番目のレイヤーだとしたら1番目のendratioからratioの半分の位置が文字列の角度 start:25 ratio40 文字列角度45
            let textAngle =  CGFloat(2 * Double.pi * textAngleRatio / Double(around) + Double.pi / 2) //
            let textLabelView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: diameter - 20, height: 20)))
            let textLabelSize = textLabelView.frame.size
            textLabelView.rouletteTextSetting(width: textLabelSize.width / 2, height: textLabelSize.height, textString, textColor, textAngle, textSize: 16)
            textLabelView.center = view.center
            graphRange.append(range)
            drawGraph(fillColor: color, startRatio, endRatio)
            graphFrameBoarder(startRatio: startRatio)
            graphFrameCircleBoarder()
            rouletteView.addSubview(textLabelView)
            startRatio = endRatio //次のグラフのスタート値を更新
        }
        rouletteView.layer.addSublayer(frameLayer)
        rouletteView.layer.insertSublayer(parentLayer, at: 0)// 最背面に配置したい時insertで0番目にする。
    }
}
//MARK: -RouletteAnimation
extension RouletteViewController {
    //ルーレットアニメーション
    func rotateAnimation(){
        startTime = CACurrentMediaTime()
        let link = CADisplayLink(target: self, selector: #selector(updateValue))
        link.preferredFramesPerSecond = 100
        link.add(to: .current, forMode: .common)
    }
    @objc func updateValue(link: CADisplayLink){
        let dataSet = rouletteDataSet.dataSet
        let dt = CGFloat((link.timestamp - self.startTime) / self.duration) //進捗率
        let degree = Degree.init(p1: CGPoint(x: 0.2, y: 0), p2: CGPoint(x: 0.2, y: 1)) //進捗率を元にイージングの計算
        let r = degree.solve(t: dt) //計算の結果を返す //進捗率が1.0に達するとそれ以上増えないように設定されているみたい
        let stopAngle = (r * dtStop) //止まる位置
        let speed = dataSet.speed //回転数
        let rotation = ((around * speed + dtStop) * r) //回転 360度*回転数+止まる角度*進捗率
        self.rouletteView.transform = CGAffineTransform(rotationAngle: rotation)
        //        print(r, stopAngle, rotation)
        //ルーレットのストップ
        if dt >= 0.99 {
            audioPlayer.volume = 0
        }
        if stopAngle >= dtStop {
            audioPlayer.stop()
            link.invalidate()
            //止まった地点の数値が各グラフの範囲だった時の判定を返す。
            graphRange.enumerated().forEach { (index, range) in
                //ルーレットの結果は針に対して回転する角度の対比側のグラフの範囲が結果になる。 30度回転した場合は針に対して反対の330度が結果になる。
                if range.contains(Double(around - stopAngle)) {
                    let list = rouletteDataSet.1[index]
                    //                    print(list.text)
                    //                    print(dtStop)
                    //                    print(range)
                    alertResultRoulette(resultText: list.text, r: list.r, g: list.g, b: list.b) //ルーレットの結果を表示する。
                    soundEffect()
                }
            }
            return
        }
    }
    //ルーレット結果の効果音
    private func soundEffect() {
        let dataSet = rouletteDataSet.dataSet
        guard let soundAsset  = NSDataAsset(name: dataSet.effect) else {
            print("not found")
            return
        }
        do{
            audioPlayer = try AVAudioPlayer(data: soundAsset.data, fileTypeHint: "wav")
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }catch{
            print(error.localizedDescription)
            audioPlayer = nil
        }
    }
}
//MARK: -RouletteResult
extension RouletteViewController: GADFullScreenContentDelegate {
    //ルーレット結果
    private func alertResultRoulette(resultText: String, r: Int, g: Int, b: Int){
        let attribute: [NSAttributedString.Key: Any] = [.font: UIFont.italicSystemFont(ofSize: 32)]
        let textSize = resultText.textSizeCalc(width: view.frame.width - 10, attribute: attribute)
        let resultLabel = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: textSize.width, height: textSize.height + 50)))
        let resultView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: resultLabel.frame.height)))
        let backView = UIView(frame: CGRect(origin: .zero, size: view.bounds.size))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAppearInterstitial))
        
        resultLabel.center = resultView.center
        resultLabel.attributedText = NSAttributedString(string: resultText, attributes: attribute)
        resultLabel.textAlignment = .center
        resultLabel.numberOfLines = 0
        //色の明るさでtextの色を変える
        if r&g&b >= 128{
            resultLabel.textColor = .black
        }
        backView.backgroundColor = .black
        backView.alpha = 0.5
        resultView.center = view.center
        resultView.transform = CGAffineTransform(translationX: view.frame.maxX, y: .zero)
        resultView.backgroundColor = UIColor(r: r, g: g, b: b)
        resultView.addSubview(resultLabel)
        
        view.addSubview(backView)
        view.addSubview(resultView)
        view.addGestureRecognizer(tapGesture)
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            resultView.transform = .identity
        }
    }
    @objc private func tapAppearInterstitial() {
        if self.interstitial != nil {
            self.interstitial?.present(fromRootViewController: self)
        } else {
            //Appleからrejectされた原因　interstitialが読み込まれなかった時にelseにdissmissを追加していなかった
            print("広告の読み込みできませんでした　Ad wasn't ready")
            dismiss(animated: true)
        }
    }
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("広告表示の失敗　Ad did fail to present full screen content.")
    }
    
    /// Tells the delegate that the ad presented full screen content.
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("広告表示の成功　Ad did present full screen content.")
    }
    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("広告を閉じる　Ad did dismiss full screen content.")
        dismiss(animated: true, completion: nil)
    }
}


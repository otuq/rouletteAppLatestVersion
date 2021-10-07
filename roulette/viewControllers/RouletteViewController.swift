//
//  RouletteViewController.swift
//  roulette
//
//  Created by USER on 2021/06/15.
//

import UIKit
import AVFoundation
import RealmSwift

class RouletteViewController: UIViewController {
    //MARK: -Properties
    private let userDefaults = UserDefaults.standard
    private let parentLayer = CALayer() //ここに各グラフを統合する
    private let frameLayer = CALayer() //ここに各グラフごとの境界線を統合する。
    private let subView = UIView() //parentLayerをセットする。
    private let around = CGFloat.pi * 2 //360度 1回転
    private let diameter: CGFloat = 360 //直径
    private let dtStop = CGFloat.random(in: 0...CGFloat.pi * 2) //止まる角度
    private let duration: TimeInterval = 10 //回る時間(秒)
    private var audioPlayer: AVAudioPlayer!
    private var startTime: CFTimeInterval! //アニメーション開始時間
    private var startRatio = 0.0 //グラフの描画開始点に使う
    private var graphRange = [ClosedRange<Double>]() //各グラフの範囲
    private var rouletteDataSet: (RouletteData, List<RouletteGraphData> ){
        guard let nav = presentingViewController as? UINavigationController,
              let homeVC = nav.viewControllers[nav.viewControllers.count - 1]as? HomeViewController,
              let dataSet = homeVC.dataSet else { return (RouletteData(), List()) }
        let list = dataSet.list
        return (dataSet, list)
    }
    //MARK:-Outlets,Actions
    @IBOutlet var tapStartLabel: [UILabel]!
    @IBOutlet weak var quitButton: UIButton!
    
    //MARK: -Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        createGraph()
        settingView()
        settingGesture()
        tapStartAnimation(labels: tapStartLabel)
    }
    private func settingView() {
        let pointerImageView = UIImageView(image: roulettePointerImage(w: 30))
        let centerCircleLabel = rouletteCenterCircleLabel(w: 40)
        let flameCircleView = rouletteFlameCircle(w: diameter)
        pointerImageView.center = CGPoint(x: view.center.x, y: view.center.y - diameter/2 - 10 )
        centerCircleLabel.center = view.center
        flameCircleView.center = view.center
        
        subView.frame = view.frame
        subView.backgroundColor = .clear
        view.addSubview(subView)
        view.addSubview(pointerImageView)
        view.addSubview(centerCircleLabel)
        view.addSubview(flameCircleView)
        view.sendSubviewToBack(subView)
        view.bringSubviewToFront(pointerImageView)
        quitButton.homeButtonAccesory()
        navigationController?.isNavigationBarHidden = true
    }
    private func settingGesture() {
        let startTapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapStart))
        view.addGestureRecognizer(startTapGesture)
        quitButton.addTarget(self, action: #selector(quitTapDismiss), for: .touchUpInside)
    }
    @objc private func quitTapDismiss() {
        let alertVC = UIAlertController(title: .none, message: "ルーレットを中止しますか？", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        let action = UIAlertAction(title: "done", style: .default) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        alertVC.addAction(cancel)
        alertVC.addAction(action)
        present(alertVC, animated: true, completion: nil)
    }
    @objc private func viewTapStart(tapGesture: UITapGestureRecognizer) {
        tapStartLabel.forEach { label in
            label.isHidden = true
        }
        quitButton.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.rotationAnimation()
            self.rouletteSoundSetting()
        }
        view.removeGestureRecognizer(tapGesture)
    }
    private func tapStartAnimation(labels: [UILabel]) {
        labels.forEach { label in
            UIView.transition(with: label, duration: 1.0, options: [.transitionCrossDissolve, .autoreverse, .repeat], animations: {
                label.layer.opacity = 0
            }) { _ in
                label.layer.opacity = 1
            }
        }
    }
    private func roulettePointerImage(w: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: w, height: w))
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: w, y: 0))
        path.addLine(to: CGPoint(x: w/2, y: w))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.close()
        UIColor.red.setFill()
        path.fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    private func rouletteCenterCircleLabel(w: CGFloat) -> UILabel {
        let circleLabel = UILabel()
        circleLabel.bounds.size = CGSize(width: w, height: w)
        circleLabel.accesory(bgColor: .white)
        return circleLabel
    }
    private func rouletteFlameCircle(w: CGFloat) -> UIView {
        let flameCircleView = UIView()
        flameCircleView.bounds.size = CGSize(width: w, height: w)
        flameCircleView.backgroundColor = .clear
        flameCircleView.layer.cornerRadius = flameCircleView.bounds.width / 2
        flameCircleView.layer.borderWidth = 2
        flameCircleView.layer.masksToBounds = true
        return flameCircleView
    }
    private func rouletteSoundSetting() {
        let dataSet = rouletteDataSet.0
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
//MARK:-CreateGraph
extension RouletteViewController {
    //円弧形グラフのパス
    private func graphPath(radius: CGFloat, startAngle: Double, endAngle: Double) -> UIBezierPath{
        let path = UIBezierPath(
            arcCenter: .zero,
            radius: radius,
            startAngle: CGFloat(2*Double.pi*startAngle/Double(around)-Double.pi/2),
            endAngle: CGFloat(2*Double.pi*endAngle/Double(around)-Double.pi/2),
            clockwise: true
        )
        path.apply(CGAffineTransform(translationX: view.center.x, y: view.center.y))
        return path
    }
    //円弧形グラフごとの境界線
    private func graphFrameBoarder(startRatio: Double) {
        let path = UIBezierPath()
        let layer = CAShapeLayer()
        let angle = CGFloat(2*Double.pi*startRatio/Double(around)-Double.pi/2)
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: diameter/2, y: 0))
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
        path.addArc(withCenter: .zero, radius: diameter/2 - 3, startAngle: 0, endAngle: around, clockwise: true)
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
        let dataSet = rouletteDataSet.0
        let list = rouletteDataSet.1
        var ratios = [CGFloat]()
        for i in list{
            let randomValue = CGFloat.random(in: 1...10)
            let sliderValue = CGFloat(i.ratio)
            let ratio = dataSet.randomFlag ? randomValue : sliderValue
            ratios.append(ratio)
        }
        let totalValue = ratios.reduce(0){$0+$1}
        let totalRatio = around/totalValue
        return ratios.map{Double($0*totalRatio)}
    }
    //viewControllerにグラフを追加
    private func createGraph(){
        let dataSet = rouletteDataSet.0
        let list = rouletteDataSet.1
        let drawRatios = drawRatios()
        drawRatios.enumerated().forEach { (index,ratio) in
            let graphData = list[index]
            let color = UIColor.init(r: graphData.r, g: graphData.g, b: graphData.b).cgColor
            let textString = graphData.text
            let textColor = dataSet.textColor
            let endRatio = startRatio + ratio
            let range = startRatio...endRatio
            let textAngleRatio = startRatio + (ratio / 2) //2番目のレイヤーだとしたら1番目のendratioからratioの半分の位置が文字列の角度 start:25 ratio40 文字列角度45
            let textAngle =  CGFloat(2*Double.pi*textAngleRatio/Double(around)+Double.pi/2) //
            let textLabelView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: diameter - 10, height: 20)))
            textLabelView.rouletteTextSetting(textString, textColor, textAngle, textSize: 16)
            textLabelView.center = view.center
            graphRange.append(range)
            drawGraph(fillColor: color, startRatio, endRatio)
            graphFrameBoarder(startRatio: startRatio)
            graphFrameCircleBoarder()
            subView.addSubview(textLabelView)
            startRatio = endRatio //次のグラフのスタート値を更新
        }
        subView.layer.addSublayer(frameLayer)
        subView.layer.insertSublayer(parentLayer, at: 0)// 最背面に配置したい時insertで0番目にする。
    }
    //ルーレットアニメーション
    func rotationAnimation(){
        startTime = CACurrentMediaTime()
        let link = CADisplayLink(target: self, selector: #selector(updateValue))
        link.preferredFramesPerSecond = 100
        link.add(to: .current, forMode: .common)
    }
    @objc func updateValue(link: CADisplayLink){
        let dataSet = rouletteDataSet.0
        let dt = CGFloat((link.timestamp - self.startTime) / self.duration) //進捗率
        let degree = Degree.init(p1: CGPoint(x: 0.2, y: 0), p2: CGPoint(x: 0.2, y: 1)) //進捗率を元にイージングの計算
        let r = degree.solve(t: dt) //計算の結果を返す //進捗率が1.0に達するとそれ以上増えないように設定されているみたい
        let stopAngle = (r * dtStop) //止まる位置
        let speed = dataSet.speed //回転数
        let rotation = ((around * speed + dtStop) * r) //回転 360度*回転数+止まる角度*進捗率
        self.subView.transform = CGAffineTransform(rotationAngle: rotation)
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
        //        print("stop:",stopAngle)
    }
    //ルーレット結果の効果音
    private func soundEffect() {
        let dataSet = rouletteDataSet.0
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
    //MARK:- resultRoulette
    //ルーレット結果
    private func alertResultRoulette(resultText: String, r: Int, g: Int, b: Int){
        let backView = UIView(frame: CGRect(origin: .zero, size: view.bounds.size))
        let resultLabel = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: 100)))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapDismiss))
        
        resultLabel.center = view.center
        resultLabel.font = UIFont.italicSystemFont(ofSize: 32)
        resultLabel.transform = CGAffineTransform(translationX: view.frame.maxX, y: .zero)
        resultLabel.backgroundColor = UIColor(r: r, g: g, b: b)
        resultLabel.text = resultText
        resultLabel.textAlignment = .center
        if r&g&b >= 128{
            resultLabel.textColor = .black
        }
        backView.backgroundColor = .black
        backView.alpha = 0.5
        backView.addGestureRecognizer(tapGesture)
        view.addSubview(backView)
        view.addSubview(resultLabel)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            resultLabel.transform = .identity
        }
    }
    @objc private func tapDismiss() {
        dismiss(animated: true, completion: nil)
    }
}

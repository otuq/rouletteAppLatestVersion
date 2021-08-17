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
    private let subView = UIView() //parentLayerをセットする。
    private let around = CGFloat.pi * 2 //360度 1回転
    private let dtStop = CGFloat.random(in: 0...CGFloat.pi * 2) //止まる角度
    private let duration: TimeInterval = 10 //回る時間
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
    //MARK: -Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        settingView()
        createGraph()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.rotationAnimation()
            self.rouletteSoundSetting()
        }
    }
    private func settingView() {
        let pointerImageView = UIImageView(image: roulettePointerImage(w: 30))
        let centerCircleLabel = rouletteCenterCircleLabel(w: 40)
        let flameCircleView = rouletteFlameCircle(w: 360)
        pointerImageView.center = CGPoint(x: view.center.x, y: view.center.y - 180 - 10 )
        centerCircleLabel.center = view.center
        flameCircleView.center = view.center
        subView.frame = view.frame
        subView.backgroundColor = .clear
        view.addSubview(subView)
        view.addSubview(pointerImageView)
        view.addSubview(centerCircleLabel)
        view.addSubview(flameCircleView)
        view.bringSubviewToFront(pointerImageView)
        navigationController?.isNavigationBarHidden = true
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
    //パスを元にイメージレイヤーを作成し、カウント分のレイヤーを親レイヤーに追加していく。
    private func drawGraph(fillColor: CGColor, _ startRatio: Double, _ endRatio: Double) {
        let circlePath = graphPath(radius: 90, startAngle: startRatio, endAngle: endRatio)
        let layer = CAShapeLayer()
        layer.path = circlePath.cgPath
        layer.lineWidth = 180
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
            let textLabelView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 350, height: 20)))
            textLabelView.rouletteTextSetting(textString, textColor, textAngle)
            textLabelView.center = view.center
            graphRange.append(range)
            drawGraph(fillColor: color, startRatio, endRatio)
            subView.addSubview(textLabelView)
            startRatio = endRatio //次のグラフのスタート値を更新
        }
        
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
//            print("stop link")
            //止まった地点の数値が各グラフの範囲だった時の判定を返す。
            graphRange.enumerated().forEach { (index, range) in
                //ルーレットの結果は針に対して回転する角度の対比側のグラフの範囲が結果になる。 30度回転した場合は針に対して反対の330度が結果になる。
                if range.contains(Double(around - stopAngle)) {
                    let list = rouletteDataSet.1
                    print(list[index].text)
                    print(dtStop)
                    print(range)
                    alertResultRoulette(resultText: list[index].text) //ルーレットの結果を表示する。
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
    //ルーレット結果
    private func alertResultRoulette(resultText: String){
        let alertVC = UIAlertController(title: "result", message: resultText, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "done", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alertVC, animated: true, completion: nil)
    }
}

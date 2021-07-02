//
//  RouletteViewController.swift
//  roulette
//
//  Created by USER on 2021/06/15.
//

import UIKit

class RouletteViewController: UIViewController {

    //MARK: -Properties
    private let parentLayer = CALayer() //ここに各グラフを統合する
    private let subView = UIView() //parentLayerをセットする。
    private let around = CGFloat.pi * 2 //360度 1回転
    private let dtStop = CGFloat.random(in: 0...CGFloat.pi * 2) //止まる角度
    private let duration: TimeInterval = 10 //回る時間
    private var startRatio = 0.0 //グラフの描画開始点に使う
    private var startTime: CFTimeInterval! //アニメーション開始時間
    private var graphRange = [ClosedRange<Double>]() //各グラフの範囲
    private var datas: [RouletteData] {
        guard let nav = presentingViewController as? UINavigationController,
              let homeVC = nav.viewControllers[nav.viewControllers.count - 1]as? HomeViewController,
              let datas = homeVC.dataSets else { return [] }
        
        return datas
    }
    
    @IBAction func doneButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: -Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        settingView()
        createGraph()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.rotationAnimation()
        }
    }
    private func settingView() {
        subView.frame = view.frame
        subView.backgroundColor = .clear
        view.addSubview(subView)
//        navigationController?.isNavigationBarHidden = true
    }
}

//MARK:-CreateGraph
extension RouletteViewController {
    //viewControllerにグラフを追加
    private func createGraph(){
        let drawRatios = drawRatios()
        drawRatios.enumerated().forEach { (index,ratio) in
            let color = datas[index].color.cgColor
            let textString = datas[index].text
            let endRatio = startRatio + ratio
            let range = startRatio...endRatio
            let textAngleRatio = startRatio + (ratio / 2)
            let textAngle =  CGFloat(2*Double.pi*textAngleRatio/Double(around)+Double.pi/2) //
            let textLabel = UILabel(frame: subView.frame).rouletteTextLabel(angle: textAngle, text: textString)
            print(textLabel.frame.origin)
            graphRange.append(range)
            drawGraph(fillColor: color, startRatio, endRatio)
            subView.addSubview(textLabel)
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
        let dt = CGFloat((link.timestamp - self.startTime) / self.duration) //進捗率
        let degree = Degree.init(p1: CGPoint(x: 0.42, y: 0), p2: CGPoint(x: 0.2, y: 1)) //進捗率を元にイージングの計算
        let r = degree.solve(t: dt) //計算の結果を返す //進捗率が1.0に達するとそれ以上増えないように設定されているみたい
        let stopAngle = (r * dtStop) //止まる位置
        let rotation = ((around * 10 + dtStop) * r) //回転 360度*回転数+止まる角度*進捗率
        self.subView.transform = CGAffineTransform(rotationAngle: rotation)
        //ルーレットのストップ
        if stopAngle >= dtStop {
            link.invalidate()
            print("stop link")
            //止まった地点の数値が各グラフの範囲だった時の判定を返す。
            graphRange.enumerated().forEach { (index, range) in
                //ルーレットの結果は針に対して回転する角度の対比側のグラフの範囲が結果になる。 30度回転した場合は針に対して反対の330度が結果になる。
                if range.contains(Double(around - stopAngle)) {
                    print(datas[index])
                    print(dtStop)
                    print(range)
                }
            }
            return
        }
        print("stop:",stopAngle)
    }
    //ランダムでグラフの幅の数値を出し、その合計を100/合計値で比率を算出する。
    private func drawRatios() -> [Double] {
        var ratios = [CGFloat]()
        for _ in 0..<datas.count{
            let randomValue = CGFloat.random(in: 1...10)
            ratios.append(randomValue)
        }
        let totalValue = ratios.reduce(0){$0+$1}
        let totalRatio = around/totalValue
        
        return ratios.map{Double($0*totalRatio)}
    }
    //円弧のパス
    private func graphPath(radius: CGFloat, startAngle: Double, endAngle: Double) -> UIBezierPath{
        let path = UIBezierPath(
            arcCenter: CGPoint(x: 0, y: 0),
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
}

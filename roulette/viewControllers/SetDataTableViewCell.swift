//
//  SetDataTableViewCell.swift
//  roulette
//
//  Created by USER on 2021/10/01.
//

import UIKit
import RealmSwift

class SetDataTableViewCell: UITableViewCell {

    //MARK: -Properties
    private let parentLayer = CALayer() //ここに各グラフを統合する
    private let frameLayer = CALayer() //ここに各グラフごとの境界線を統合する。
    private let around = CGFloat.pi * 2 //360度 1回転
    private let diameter: CGFloat = 150 //直径
    private let frameLineWidth: CGFloat = 2
    private var startRatio = 0.0 //グラフの描画開始点に使う
    private var graphRange = [ClosedRange<Double>]() //各グラフの範囲
    private var maxPoint: CGPoint {
        CGPoint(x: rouletteView.frame.maxX - 30, y: rouletteView.frame.maxY + 5)
    }
    var dataset: RouletteData? {
        didSet{
            guard let dataset = dataset else { return }
            let list = dataset.list
            textLabel?.text = dataset.title.isEmpty ? "No title" : dataset.title
            createGraph(data: dataset, list: list)
        }
    }

    //MARK: -Outletes, Actions
    @IBOutlet weak var rouletteView: UIView!
    
    //MARK: -LifeCycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        overrideUserInterfaceStyle = .light
        settingView()
    }
    private func settingView() {
        let centerCircleLabel = rouletteCenterCircleLabel(w: 15)
        let flameCircleView = rouletteFlameCircle(w: diameter)
        let selectView = UIView()
        centerCircleLabel.center = maxPoint
        flameCircleView.center = maxPoint
//        selectView.backgroundColor = UIColor.init(r: 0, g: 0, b: 0, a: 0.1)
        selectedBackgroundView = selectView
        rouletteView.addSubview(centerCircleLabel)
        rouletteView.addSubview(flameCircleView)
    }
    private func rouletteCenterCircleLabel(w: CGFloat) -> UILabel {
        let circleLabel = UILabel()
        circleLabel.bounds.size = CGSize(width: w, height: w)
        circleLabel.decoration(bgColor: .white)
        return circleLabel
    }
    private func rouletteFlameCircle(w: CGFloat) -> UIView {
        let flameCircleView = UIView()
        flameCircleView.bounds.size = CGSize(width: w, height: w)
        flameCircleView.backgroundColor = .clear
        flameCircleView.layer.cornerRadius = flameCircleView.bounds.width / 2
        flameCircleView.layer.borderWidth = 1
        flameCircleView.layer.masksToBounds = true
        return flameCircleView
    }
    //円弧形グラフのパス
    private func graphPath(radius: CGFloat, startAngle: Double, endAngle: Double) -> UIBezierPath{
        let path = UIBezierPath(
            arcCenter: .zero,
            radius: radius,
            startAngle: CGFloat(2*Double.pi*startAngle/Double(around)-Double.pi/2),
            endAngle: CGFloat(2*Double.pi*endAngle/Double(around)-Double.pi/2),
            clockwise: true
        )
        path.apply(CGAffineTransform(translationX: maxPoint.x, y: maxPoint.y))
        return path
    }
    //円弧形グラフごとの境界線
    private func graphFrameBoarder(startRatio: Double) {
        let path = UIBezierPath()
        let layer = CAShapeLayer()
        let angle = CGFloat(2*Double.pi*startRatio/Double(around)-Double.pi/2)
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: diameter/2 - frameLineWidth, y: 0))
        path.apply(CGAffineTransform(rotationAngle: angle))
        path.apply(CGAffineTransform(translationX: maxPoint.x, y: maxPoint.y))
        layer.path = path.cgPath
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = frameLineWidth
        frameLayer.addSublayer(layer)
    }
    //円グラフの内側円線
    private func graphFrameCircleBoarder() {
        let path = UIBezierPath()
        let layer = CAShapeLayer()
        path.addArc(withCenter: .zero, radius: diameter/2 - frameLineWidth, startAngle: 0, endAngle: around, clockwise: true)
        path.apply(CGAffineTransform(translationX: maxPoint.x, y: maxPoint.y))
        layer.fillColor = UIColor.clear.cgColor
        layer.path = path.cgPath
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = frameLineWidth
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
    private func drawRatios(list: List<RouletteGraphData>) -> [Double] {
        let list = list
        var ratios = [CGFloat]()
        for i in list{
            let ratio = CGFloat(i.ratio)
            ratios.append(ratio)
        }
        let totalValue = ratios.reduce(0){$0+$1}
        let totalRatio = around/totalValue
        return ratios.map{Double($0*totalRatio)}
    }
    //viewControllerにグラフを追加
    private func createGraph(data: RouletteData, list: List<RouletteGraphData>){
        let drawRatios = drawRatios(list: list)
        drawRatios.enumerated().forEach { (index,ratio) in
            let graphData = list[index]
            let color = UIColor.init(r: graphData.r, g: graphData.g, b: graphData.b).cgColor
            let textString = graphData.text
            let textColor = data.textColor
            let endRatio = startRatio + ratio
            let range = startRatio...endRatio
            let textAngleRatio = startRatio + (ratio / 2) //2番目のレイヤーだとしたら1番目のendratioからratioの半分の位置が文字列の角度 start:25 ratio40 文字列角度45
            let textAngle =  CGFloat(2*Double.pi*textAngleRatio/Double(around)+Double.pi/2) //
            let textLabelView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: diameter - 10, height: 20)))
            textLabelView.rouletteTextSetting(textString, textColor, textAngle, textSize: 10)
            textLabelView.center = maxPoint
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

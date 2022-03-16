//
//  RouletteView.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/14.
//

import UIKit
import RealmSwift

protocol ShareProperty {}
extension ShareProperty {
    internal var around: CGFloat { CGFloat.pi * 2 } // 360度 1回転
    internal var diameter: CGFloat {
        let width = UIScreen.main.bounds.width
        let subtraction = (width / 13) / 2
        return (width - subtraction)
    }// 直径
}

class RouletteView: UIView, ShareProperty {
    private var output: (dataSet: RouletteData, list: List<RouletteGraphData>)!
    private let roulettelayer = RouletteLayer.shared
    private var startRatio = 0.0 // グラフの描画開始点に使う
    internal var graphRange = [ClosedRange<Double>]() // 各グラフの範囲

    init(output: (dataSet: RouletteData, list: List<RouletteGraphData>)) {
        super.init(frame: .zero)
        self.output = output
        addCreateGraph()
    }
    //グラフレイヤーをviewに追加
    private func addCreateGraph(){
        let parentLayer = CALayer() // ここに各グラフを統合する
        let frameLayer = CALayer() // ここに各グラフごとの境界線を統合する。
        let frameCircleLayer = roulettelayer.graphFrameCircleBoarder()
        let calcRatios = createRatios()
        calcRatios.enumerated().forEach { index, ratio in
            let graphData = output.list[index]
            let graphColor = UIColor.init(r: graphData.r, g: graphData.g, b: graphData.b).cgColor
            let createGraph = self.createGraph(ratio: ratio, graphColor: graphColor)
            parentLayer.addSublayer(createGraph.graph)
            frameLayer.addSublayer(createGraph.frame)
        }
        frameLayer.addSublayer(frameCircleLayer)
        self.layer.addSublayer(frameLayer)
        self.layer.insertSublayer(parentLayer, at: 0)// 最背面に配置したい時insertで0番目にする。
    }
    // グラフの比率を算出
    private func createRatios() -> [Double] {
        var ratios = [CGFloat]()
        for i in output.list {
            let randomValue = Float.random(in: 1...10)
            let sliderValue = Float(i.ratio)
            let ratio = output.dataset?.randomFlag ? randomValue : sliderValue
            ratios.append(ratio)
        }
        // グラフの幅の数値の合計を100/合計値で比率を算出する。
        let totalValue = ratios.reduce(0) { $0 + $1 }
        let totalRatio = self.around / CGFloat(totalValue)
        let calcRatios = ratios.map { Double($0 * totalRatio) }
        return calcRatios
    }
    // 比率ごとにグラフとフレームを作成
    private func createGraph(ratio: Double, graphColor: CGColor) -> (graph: CALayer, frame: CALayer) {
        let endRatio = startRatio + ratio
        let range = startRatio...endRatio
        let frameBoarderLayer = roulettelayer.graphFrameBoarder(startRatio: startRatio)
        let graphLayer = roulettelayer.drawGraph(fillColor: graphColor, startRatio, endRatio)
        graphRange.append(range)
        startRatio = endRatio // 次のグラフのスタート値を更新
        return (graphLayer, frameBoarderLayer)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//class RouletteTextLabel: UILabel {
//    let textAngleRatio = startRatio + (ratio / 2) // 2番目のレイヤーだとしたら1番目のendratioからratioの半分の位置が文字列の角度 start:25 ratio40 文字列角度45
//    let textAngle = CGFloat(2 * Double.pi * textAngleRatio / Double(around) + Double.pi / 2) //
//    let textLabelView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: diameter - 20, height: 20)))
//    textLabelView.rouletteTextSetting(text, textColor, textAngle, textSize: 16)
//    textLabelView.center = self.center
//    self.addSubview(textLabelView)
//}

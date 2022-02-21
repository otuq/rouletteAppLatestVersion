//
//  rouletteModule.swift
//  roulette
//
//  Created by USER on 2022/02/21.
//

import UIKit
import RealmSwift
import AVFoundation

//MARK: -CreateRouletteView

class CreateRouletteView: UIView {
    internal let around = CGFloat.pi * 2 //360度 1回転
    internal let dtStop = CGFloat.random(in: 0...CGFloat.pi * 2) //止まる角度
    internal let duration: TimeInterval = 10 //回る時間(秒)
    internal let diameter: CGFloat = {
        let width = UIScreen.main.bounds.width
        let subtraction = (width / 13) / 2
        return (width - subtraction)
    }() //直径
    internal var graphRange = [ClosedRange<Double>]() //各グラフの範囲
    internal var audioPlayer: AVAudioPlayer!
    internal var startTime: CFTimeInterval! //アニメーション開始時間
    private var startRatio = 0.0 //グラフの描画開始点に使う

    var rouletteDataSet: (dataSet: RouletteData, list: List<RouletteGraphData>)! 
    
    //MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: ルーレットの音楽
    func rouletteSoundSetting() {
        let dataSet = rouletteDataSet.dataSet
        guard let soundAsset  = NSDataAsset(name: dataSet.sound) else {
            print("not found sound data")
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
    //MARK: viewにグラフを追加
    func createGraph(){
        let dataSet = rouletteDataSet.dataSet
        let list = rouletteDataSet.list
        let parentLayer = CALayer() //ここに各グラフを統合する
        let frameLayer = CALayer() //ここに各グラフごとの境界線を統合する。
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
            textLabelView.center = self.center
            graphRange.append(range)
            
            parentLayer.addSublayer(drawGraph(fillColor: color, startRatio, endRatio))
            [graphFrameBoarder(startRatio: startRatio),
             graphFrameCircleBoarder()].forEach { add in
                layer.addSublayer(add)
            }
            addSubview(textLabelView)
            startRatio = endRatio //次のグラフのスタート値を更新
        }
        layer.addSublayer(frameLayer)
        layer.insertSublayer(parentLayer, at: 0)// 最背面に配置したい時insertで0番目にする。
    }
    //MARK: 円弧形グラフごとの境界線
    private func graphFrameBoarder(startRatio: Double) -> CAShapeLayer{
        let path = UIBezierPath()
        let layer = CAShapeLayer()
        let angle = CGFloat(2 * Double.pi * startRatio / Double(around) - Double.pi / 2)
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: (diameter / 2) - 3, y: 0))
        path.apply(CGAffineTransform(rotationAngle: angle))
        path.apply(CGAffineTransform(translationX: self.center.x, y: self.center.y))
        layer.path = path.cgPath
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 3
        return layer
    }
    //MARK: 円グラフの内側円線
    private func graphFrameCircleBoarder() -> CAShapeLayer {
        let path = UIBezierPath()
        let layer = CAShapeLayer()
        path.addArc(withCenter: .zero, radius: (diameter / 2) - 3, startAngle: 0, endAngle: around, clockwise: true)
        path.apply(CGAffineTransform(translationX: self.center.x, y: self.center.y))
        layer.fillColor = UIColor.clear.cgColor
        layer.path = path.cgPath
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 3
        return layer
    }
    //MARK: 円弧形グラフのパス
    private func graphPath(radius: CGFloat, startAngle: Double, endAngle: Double) -> UIBezierPath{
        let path = UIBezierPath(
            arcCenter: .zero,
            radius: radius,
            startAngle: CGFloat(2 * Double.pi * startAngle / Double(around) - Double.pi / 2),
            endAngle: CGFloat(2 * Double.pi * endAngle / Double(around) - Double.pi / 2),
            clockwise: true
        )
        path.apply(CGAffineTransform(translationX: self.center.x, y: self.center.y))
        return path
    }
    //MARK: パスを元にイメージレイヤーを作成し、カウント分のレイヤーを親レイヤーに追加していく。
    private func drawGraph(fillColor: CGColor, _ startRatio: Double, _ endRatio: Double) -> CAShapeLayer {
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
        return layer
    }
    //MARK: グラフの幅の数値の合計を100/合計値で比率を算出する。
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
}

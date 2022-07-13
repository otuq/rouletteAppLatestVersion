//
//  RouletteView.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/14.
//

import AVFoundation
import UIKit

class RouletteView: UIView, ShareProperty, ShareModel {
    private let dtStop = CGFloat.random(in: 0...CGFloat.pi * 2) // 止まる角度
    private let duration: TimeInterval = 10 // 回る時間(秒)
    private var audioPlayer: AVAudioPlayer?
    private var startTime: CFTimeInterval! // アニメーション開始時間

    private var rouletteDataSet: DataSet!
    private var roulettelayer: RouletteLayer!
    private var startRatio = 0.0 // グラフの描画開始点に使う
    var graphRange = [ClosedRange<Double>]() // 各グラフの範囲

    init(dataSet: DataSet) {
        super.init(frame: .zero)
        self.rouletteDataSet = dataSet
        roulettelayer = RouletteLayer(viewPoint: self.center)
        addGraphAndFrame()
    }
    // グラフレイヤーをviewに追加
    private func addGraphAndFrame() {
        let parentLayer = CALayer() // ここに各グラフを統合する
        let frameLayer = CALayer() // ここに各グラフごとの境界線を統合する。
        let frameCircleLayer = roulettelayer.innerCircleBorderLayer()
        let calcRatios = calcRatios()
        calcRatios.enumerated().forEach { index, ratio in
            let dataSet = rouletteDataSet.dataSet
            let list = rouletteDataSet.list[index]
            let endRatio = startRatio + ratio
            let graphColor = UIColor(r: list.r, g: list.g, b: list.b).cgColor
            let createGraph = self.createGraphAndFrame(endRatio: endRatio, graphColor: graphColor)
            let rouletteText = rouletteText(list.text, dataSet.textColor, textSize: 16, ratio: ratio)
            rouletteText.center = self.center
            parentLayer.addSublayer(createGraph.graph)
            frameLayer.addSublayer(createGraph.frame)
            addSubview(rouletteText)
            startRatio = endRatio // 次のグラフのスタート値を更新
        }
        frameLayer.addSublayer(frameCircleLayer)
        self.layer.addSublayer(frameLayer)
        self.layer.insertSublayer(parentLayer, at: 0)// 最背面に配置したい時insertで0番目にする。
    }
    // グラフの比率を算出
    private func calcRatios() -> [Double] {
        var ratios = [CGFloat]()
        for i in rouletteDataSet.list {
            let randomValue = CGFloat.random(in: 1...10)
            let sliderValue = CGFloat(i.ratio)
            let ratio = rouletteDataSet.dataSet.randomFlag ? randomValue : sliderValue
            ratios.append(ratio)
        }
        // グラフの幅の数値の合計を100/合計値で比率を算出する。
        let totalValue = ratios.reduce(0) { $0 + $1 }
        let totalRatio = around / totalValue
        return ratios.map { Double($0 * totalRatio) }
    }
    // 比率ごとにグラフとフレームを作成
    private func createGraphAndFrame(endRatio: Double, graphColor: CGColor) -> (graph: CALayer, frame: CALayer) {
        let range = startRatio...endRatio
        let frameBoarderLayer = roulettelayer.arcBorderLayer(startRatio: startRatio)
        let graphLayer = roulettelayer.drawGraphLayer(fillColor: graphColor, startRatio, endRatio)
        graphRange.append(range)
        return (graphLayer, frameBoarderLayer)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func rouletteText(_ text: String, _ textColor: UIColor, textSize: CGFloat, ratio: CGFloat) -> UIView {
        let textLabelView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: diameter - 20, height: 20)))
        let textAngleRatio = startRatio + (ratio / 2) // 2番目のレイヤーだとしたら1番目のendratioからratioの半分の位置が文字列の角度 start:25 ratio40 文字列角度45
        let textAngle = CGFloat(2 * Double.pi * textAngleRatio / Double(around) + Double.pi / 2)
        textLabelView.rouletteTextSetting(text, textColor, textAngle, textSize: 16)
        return textLabelView
    }
    // ルーレットアニメーション
    func startRotateAnimation() {
        startTime = CACurrentMediaTime()
        let link = CADisplayLink(target: self, selector: #selector(updateValue))
        link.preferredFramesPerSecond = 100
        link.add(to: .current, forMode: .common)
    }
    @objc func updateValue(link: CADisplayLink) {
        let dt = CGFloat((link.timestamp - startTime) / duration) // 進捗率
        let degree = Degree(p1: CGPoint(x: 0.2, y: 0), p2: CGPoint(x: 0.2, y: 1)) // 進捗率を元にイージングの計算
        let r = degree.solve(t: dt) // 計算の結果を返す //進捗率が1.0に達するとそれ以上増えないように設定されているみたい
        let stopAngle = (r * dtStop) // 止まる位置
        let rotation = ((CGFloat(around) * rouletteDataSet.dataSet.speed + dtStop) * r) // 回転 360度*回転数+止まる角度*進捗率
        transform = CGAffineTransform(rotationAngle: rotation)
        // ルーレットのストップ
        if stopAngle >= dtStop {
            link.invalidate()
            // 止まった地点の数値が各グラフの範囲だった時の判定を返す。
            graphRange.enumerated().forEach { index, range in
                // ルーレットの結果は針に対して回転する角度の対比側のグラフの範囲が結果になる。 30度回転した場合は針に対して反対の330度が結果になる。
                if range.contains(Double(around - stopAngle)) {
                    let list = rouletteDataSet.list[index]
                    alertResultRoulette(resultText: list.text, r: list.r, g: list.g, b: list.b) // ルーレットの結果を表示する。
                    soundEffect()
                }
            }
            return
        }
    }
    // ルーレットの音楽
    func rouletteSoundSetting() {
        guard let soundAsset = NSDataAsset(name: rouletteDataSet.dataSet.sound) else {
            print("not found sound data")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(data: soundAsset.data, fileTypeHint: "wav")
            audioPlayer?.prepareToPlay()
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        } catch {
            print(error.localizedDescription)
            audioPlayer = nil
        }
    }
    // ルーレット結果の効果音
    private func soundEffect() {
        guard let soundAsset = NSDataAsset(name: rouletteDataSet.dataSet.effect) else {
            print("not found")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(data: soundAsset.data, fileTypeHint: "wav")
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("エラー：\(error.localizedDescription)")
            audioPlayer = nil
        }
    }
    // ルーレット結果
    private func alertResultRoulette(resultText: String, r: Int, g: Int, b: Int) {
        guard let rootVC = parentViewController as? RouletteViewController,
              let rootView = rootVC.view else { return }
        let attribute: [NSAttributedString.Key: Any] = [.font: UIFont.italicSystemFont(ofSize: 32)]
        let textSize = resultText.textSizeCalc(width: rootView.frame.width - 10, attribute: attribute)
        let resultLabel = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: textSize.width, height: textSize.height + 50)))
        let resultView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: rootView.frame.width, height: resultLabel.frame.height)))
        let backView = UIView(frame: CGRect(origin: .zero, size: rootView.bounds.size))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapDismiss))
        
        resultLabel.center = resultView.center
        resultLabel.attributedText = NSAttributedString(string: resultText, attributes: attribute)
        resultLabel.textAlignment = .center
        resultLabel.numberOfLines = 0
        
        // 色の明るさでtextの色を変える
        if r & g & b >= 128 {
            resultLabel.textColor = .black
        }
        backView.backgroundColor = .black.withAlphaComponent(0.5)
        resultView.center = rootView.center
        resultView.transform = CGAffineTransform(translationX: rootView.frame.maxX, y: .zero)
        resultView.backgroundColor = UIColor(r: r, g: g, b: b)
        resultView.addSubview(resultLabel)
        
        rootView.addSubview(backView)
        rootView.addSubview(resultView)
        rootView.addGestureRecognizer(tapGesture)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            resultView.transform = .identity
        }
    }
    @objc private func tapDismiss() {
        parentViewController?.dismiss(animated: true)
    }
}

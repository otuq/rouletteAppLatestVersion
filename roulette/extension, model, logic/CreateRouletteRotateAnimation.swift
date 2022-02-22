//
//  RotateAnimation.swift
//  roulette
//
//  Created by USER on 2022/02/21.
//

import AVFoundation
import RealmSwift
import UIKit

extension CreateRouletteView {
    // ルーレットアニメーション
    func startRotateAnimation() {
        startTime = CACurrentMediaTime()
        let link = CADisplayLink(target: self, selector: #selector(updateValue))
        link.preferredFramesPerSecond = 100
        link.add(to: .current, forMode: .common)
    }

    @objc func updateValue(link: CADisplayLink) {
        let dataSet = rouletteDataSet.dataSet
        let dt = CGFloat((link.timestamp - self.startTime) / self.duration) // 進捗率
        let degree = Degree(p1: CGPoint(x: 0.2, y: 0), p2: CGPoint(x: 0.2, y: 1)) // 進捗率を元にイージングの計算
        let r = degree.solve(t: dt) // 計算の結果を返す //進捗率が1.0に達するとそれ以上増えないように設定されているみたい
        let stopAngle = (r * dtStop) // 止まる位置
        let speed = dataSet.speed // 回転数
        let rotation = ((around * speed + dtStop) * r) // 回転 360度*回転数+止まる角度*進捗率
        transform = CGAffineTransform(rotationAngle: rotation)
        //        print(r, stopAngle, rotation)
        // ルーレットのストップ
        if dt >= 0.99 {
            audioPlayer.volume = 0
        }
        if stopAngle >= dtStop {
            audioPlayer.stop()
            link.invalidate()
            // 止まった地点の数値が各グラフの範囲だった時の判定を返す。
            graphRange.enumerated().forEach { index, range in
                // ルーレットの結果は針に対して回転する角度の対比側のグラフの範囲が結果になる。 30度回転した場合は針に対して反対の330度が結果になる。
                if range.contains(Double(around - stopAngle)) {
                    let list = rouletteDataSet.1[index]
                    //                    print(list.text)
                    //                    print(dtStop)
                    //                    print(range)
                    alertResultRoulette(resultText: list.text, r: list.r, g: list.g, b: list.b) // ルーレットの結果を表示する。
                    soundEffect()
                }
            }
            return
        }
    }
    // ルーレット結果
    private func alertResultRoulette(resultText: String, r: Int, g: Int, b: Int) {
        guard let rootVC = parentViewController as? RouletteViewController,
              let view = rootVC.view else { return }
        let attribute: [NSAttributedString.Key: Any] = [.font: UIFont.italicSystemFont(ofSize: 32)]
        let textSize = resultText.textSizeCalc(width: view.frame.width - 10, attribute: attribute)
        let resultLabel = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: textSize.width, height: textSize.height + 50)))
        let resultView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: resultLabel.frame.height)))
        let backView = UIView(frame: CGRect(origin: .zero, size: view.bounds.size))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapDissmiss))

        resultLabel.center = resultView.center
        resultLabel.attributedText = NSAttributedString(string: resultText, attributes: attribute)
        resultLabel.textAlignment = .center
        resultLabel.numberOfLines = 0

        // 色の明るさでtextの色を変える
        if r & g & b >= 128 {
            resultLabel.textColor = .black
        }
        backView.backgroundColor = .black.withAlphaComponent(0.5)
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
    @objc private func tapDissmiss() {
        print("tap")
        parentViewController?.dismiss(animated: true)
    }
    // ルーレット結果の効果音
    private func soundEffect() {
        let dataSet = rouletteDataSet.dataSet
        guard let soundAsset = NSDataAsset(name: dataSet.effect) else {
            print("not found")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(data: soundAsset.data, fileTypeHint: "wav")
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            print(error.localizedDescription)
            audioPlayer = nil
        }
    }
}

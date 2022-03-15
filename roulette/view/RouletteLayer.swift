//
//  RouletteLayer.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/15.
//

import UIKit

class RouletteLayer: ShareProperty {
    static let shared = RouletteLayer()
    // 円グラフの内側円線
    func graphFrameCircleBoarder() -> CAShapeLayer {
        let path = UIBezierPath()
        let layer = CAShapeLayer()
        path.addArc(withCenter: .zero, radius: (diameter / 2) - 3, startAngle: 0, endAngle: CGFloat(around), clockwise: true)
        path.apply(CGAffineTransform(translationX: layer.frame.midX, y: layer.frame.midY))
        layer.fillColor = UIColor.clear.cgColor
        layer.path = path.cgPath
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 3
        return layer
    }
    // 円弧形グラフごとの境界線
    func graphFrameBoarder(startRatio: Double) -> CAShapeLayer {
        let path = UIBezierPath()
        let layer = CAShapeLayer()
        let angle = CGFloat(2 * Double.pi * startRatio / Double(around) - Double.pi / 2)
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: (diameter / 2) - 3, y: 0))
        path.apply(CGAffineTransform(rotationAngle: angle))
        path.apply(CGAffineTransform(translationX: layer.frame.midX, y: layer.frame.midY))
        layer.path = path.cgPath
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 3
        return layer
    }
    // パスを元にイメージレイヤーを作成し、カウント分のレイヤーを親レイヤーに追加していく。
    func drawGraph(fillColor: CGColor, _ startRatio: Double, _ endRatio: Double) -> CAShapeLayer {
        let circlePath = graphPath(radius: diameter / 4, startAngle: startRatio, endAngle: endRatio)
        let layer = CAShapeLayer()
        layer.path = circlePath.cgPath
        layer.lineWidth = diameter / 2
        layer.lineCap = .butt
        layer.strokeColor = fillColor
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeStart = 0
        layer.strokeEnd = 1
        // 親レイヤーに描画するレイヤーを追加していく
        return layer
    }
    // 円弧形グラフのパス
    private func graphPath(radius: CGFloat, startAngle: Double, endAngle: Double) -> UIBezierPath {
        let path = UIBezierPath(
            arcCenter: .zero,
            radius: radius,
            startAngle: CGFloat(2 * Double.pi * startAngle / Double(around) - Double.pi / 2),
            endAngle: CGFloat(2 * Double.pi * endAngle / Double(around) - Double.pi / 2),
            clockwise: true
        )
        path.apply(CGAffineTransform(translationX: path.bounds.midX, y: path.bounds.midY))
        return path
    }
}

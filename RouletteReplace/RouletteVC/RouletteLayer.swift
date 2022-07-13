//
//  RouletteLayer.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/15.
//

import UIKit

protocol ShareProperty {}
extension ShareProperty {
    var around: CGFloat { CGFloat.pi * 2 } // 360度 1回転
    var diameter: CGFloat {
        let width = UIScreen.main.bounds.width
        let subtraction = (width / 13) / 2
        return (width - subtraction)
    }// 直径
}
class RouletteLayer: ShareProperty {
    private var viewPoint: CGPoint!
    init(viewPoint: CGPoint) {
        self.viewPoint = viewPoint
    }
    // 円グラフの内側円線
    func innerCircleBorderLayer() -> CAShapeLayer {
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
    func arcBorderLayer(startRatio: Double) -> CAShapeLayer {
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
    func drawGraphLayer(fillColor: CGColor, _ startRatio: Double, _ endRatio: Double) -> CAShapeLayer {
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
        // グラフの位置をviewに合わせる
        path.apply(CGAffineTransform(translationX: viewPoint.x, y: viewPoint.y))
        return path
    }
}

//
//  RoulettePointer.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/08.
//

import UIKit

class RouletteModule: ShareProperty {
    private var output: RouletteOutput!
    var d: CGFloat = {
        let width = UIScreen.main.bounds.width
        let subtraction = (width / 13) / 2
        return (width - subtraction)
    }()
     var w: CGFloat = {
        CGFloat(30).recalcValue
    }()
    init(output: RouletteOutput) {
        self.output = output
    }
    // ルーレットの針
    func addPointer() {
        UIGraphicsBeginImageContext(CGSize(width: w, height: w))
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: w, y: 0))
        path.addLine(to: CGPoint(x: w / 2, y: w))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.close()
        UIColor.red.setFill()
        path.fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let imageView = UIImageView(image: image)
        imageView.center = CGPoint(x: output.vc.view.center.x, y: (output.vc.view.center.y - d / 2) - (w / 2) + 5 )
        output.vc.view.addSubview(imageView)
        output.vc.view.bringSubviewToFront(imageView)
    }
    // ルーレットの真ん中のオブジェクト
    func addCenterCircle() {
        let circleLabel = UILabel()
        circleLabel.bounds.size = CGSize(width: w, height: w)
        circleLabel.decoration(bgColor: .white)
        circleLabel.center = output.vc.view.center
        output.vc.view.addSubview(circleLabel)
    }
    // ルーレットの外側円線
    func addFrameCircle() {
        let frameCircleView = UIView()
        frameCircleView.bounds.size = CGSize(width: d, height: d)
        frameCircleView.backgroundColor = .clear
        frameCircleView.layer.cornerRadius = frameCircleView.bounds.width / 2
        frameCircleView.layer.borderWidth = 2
        frameCircleView.layer.masksToBounds = true
        frameCircleView.center = output.vc.view.center
        output.vc.view.addSubview(frameCircleView)
    }
}

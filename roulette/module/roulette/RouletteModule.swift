//
//  RoulettePointer.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/08.
//

import UIKit

class RouletteModule {
    private weak var input: InterfaceInput!

    init(input: InterfaceInput) {
        self.input = input
    }
    // ルーレット
    func addRoulette() {
        let rouletteView = input.vw
        rouletteView.frame = input.vc.view.bounds
        rouletteView.backgroundColor = .clear
        rouletteView.createGraph()

        input.vc.view.addSubview(rouletteView)
        input.vc.view.sendSubviewToBack(rouletteView)
    }
    // ルーレットの針
    func addPointer() {
        UIGraphicsBeginImageContext(CGSize(width: input.w, height: input.w))
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: input.w, y: 0))
        path.addLine(to: CGPoint(x: input.w / 2, y: input.w))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.close()
        UIColor.red.setFill()
        path.fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let imageView = UIImageView(image: image)
        imageView.center = viewlayout()
        input.vc.view.addSubview(imageView)
        input.vc.view.bringSubviewToFront(imageView)
    }
    private func viewlayout() -> CGPoint {
        CGPoint(x: input.vw.center.x, y: (input.vw.center.y - input.d / 2) - (input.w / 2) + 5 )
    }
    // ルーレットの真ん中のオブジェクト
    func addCenterCircle() {
        let circleLabel = UILabel()
        circleLabel.bounds.size = CGSize(width: input.w, height: input.w)
        circleLabel.decoration(bgColor: .white)
        circleLabel.center = input.vc.view.center
        input.vc.view.addSubview(circleLabel)
    }
    // ルーレットの外側円線
    func addFrameCircle() {
        let frameCircleView = UIView()
        frameCircleView.bounds.size = CGSize(width: input.d, height: input.d)
        frameCircleView.backgroundColor = .clear
        frameCircleView.layer.cornerRadius = frameCircleView.bounds.width / 2
        frameCircleView.layer.borderWidth = 2
        frameCircleView.layer.masksToBounds = true
        frameCircleView.center = input.vc.view.center
        input.vc.view.addSubview(frameCircleView)
    }
}

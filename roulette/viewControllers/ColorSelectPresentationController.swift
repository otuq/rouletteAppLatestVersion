//
//  ColorSelectPresentationController.swift
//  roulette
//
//  Created by USER on 2021/06/23.
//

import UIKit

class ColorsSelectPresentationController: UIPresentationController {
    //MARK:-properties
    private let margin = (x: CGFloat(50), y: CGFloat(400))
    //バックビュー
    private let overLayView: UIView = {
        let overLay = UIView()
        overLay.backgroundColor = .black
        overLay.alpha = 0

        return overLay
    }()
    
    //MARK:-LifeCycle Methods
    //親コンテナのサイズをmarginで差し引いたサイズを計算する。
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        CGSize(width: parentSize.width - margin.x, height: parentSize.height - margin.y)
    }
    //サイズを計算してこのframeを呼び出し先のVCのframeにセットする。
    override var frameOfPresentedViewInContainerView: CGRect {
        var frame = CGRect()
        let containerSize = containerView!.bounds
        let contentSize = size(forChildContentContainer: presentingViewController, withParentContainerSize: containerSize.size)
        frame.size = contentSize
        frame.origin = CGPoint(x: margin.x/2, y: margin.y/2)
        
        return frame
    }
    //表示トランジション開始前
    override func presentationTransitionWillBegin() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapDismiss))
        overLayView.addGestureRecognizer(tapGesture)
        //親コンテナの最下層にバックビューを挿入
        containerView?.insertSubview(overLayView, at: 0)
        //トランジションの開始後
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.overLayView.alpha = 0.5
        })
    }
    //表示トランジション開始後
//    override func presentationTransitionDidEnd(_ completed: Bool) {
//
//    }
    //非表示トランジション開始前
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.overLayView.alpha = 0
        })
    }
    //非表示トランジション開始後
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        //dismissが完了
        if completed {
            self.overLayView.removeFromSuperview()
        }
    }
    //レイアウト開始後　presentedViewは呼び出し先のVC overLayVCはその一枚下の階層の半透明の背景View
    override func containerViewDidLayoutSubviews() {
        overLayView.frame = containerView!.bounds
        presentedView?.frame = frameOfPresentedViewInContainerView
        presentedView?.layer.cornerRadius = 20
    }
    @objc func tapDismiss() {
        presentingViewController.dismiss(animated: true)
    }
}


//
//  RouletteViewController.swift
//  roulette
//
//  Created by USER on 2021/06/15.
//

import UIKit
import AVFoundation
import RealmSwift

class RouletteViewController: UIViewController {
    //MARK: -Properties
    private let rouletteView = CreateRouletteView()
    private let objectWidth: CGFloat = CGFloat(30).recalcValue
    private var audioPlayer: AVAudioPlayer!
    private let diameter: CGFloat = {
        let width = UIScreen.main.bounds.width
        let subtraction = (width / 13) / 2
        return (width - subtraction)
    }() //直径
    var rouletteDataSet: (dataSet: RouletteData, list: List<RouletteGraphData>)!{
        didSet{
            guard rouletteDataSet != nil else { return print("detaSetがありません") }
            print(rouletteDataSet.dataSet.sound)
            rouletteView.rouletteDataSet = rouletteDataSet
        }
    }

    //MARK: -Outlets,Actions
    @IBOutlet var tapStartLabel: [UILabel]!
    @IBOutlet weak var quitButton: UIButton!
    
    //MARK: -Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        settingUI()
        settingView()
        settingGesture()
        fontSizeRecalcForEachDevice()
        blinkAnimation(labels: tapStartLabel)
    }
    private func settingUI() {
        quitButton.imageSet()
        quitButton.fontSizeRecalcForEachDevice()
    }
    private func settingView() {
        let pointerImageView = UIImageView(image: roulettePointerImage(w: objectWidth))
        let centerCircleLabel = rouletteCenterCircleLabel(w: objectWidth)
        let frameCircleView = rouletteFrameCircle(w: diameter)
        pointerImageView.center = CGPoint(x: view.center.x, y: (view.center.y - diameter / 2) - (objectWidth / 2) + 5 )
        centerCircleLabel.center = view.center
        frameCircleView.center = view.center
        
        rouletteView.frame = view.frame
        rouletteView.backgroundColor = .clear
        rouletteView.createGraph()
        
        view.addSubview(rouletteView)
        view.addSubview(pointerImageView)
        view.addSubview(centerCircleLabel)
        view.addSubview(frameCircleView)
        view.sendSubviewToBack(rouletteView)
        view.bringSubviewToFront(pointerImageView)
        navigationController?.isNavigationBarHidden = true
    }
    private func settingGesture() {
        let startTapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapStart))
        view.addGestureRecognizer(startTapGesture)
        quitButton.addTarget(self, action: #selector(quitTapDismiss), for: .touchUpInside)
    }
    
    //デバイス毎にUIのテキストサイズを再計算
    private func fontSizeRecalcForEachDevice() {
        tapStartLabel.forEach { $0.fontSizeRecalcForEachDevice() }
        quitButton.fontSizeRecalcForEachDevice()
    }
    //ルーレットを中止
    @objc private func quitTapDismiss() {
        let alertVC = UIAlertController(title: .none, message: "ルーレットを中止しますか？", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        let action = UIAlertAction(title: "中止する", style: .default) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        alertVC.addAction(cancel)
        alertVC.addAction(action)
        present(alertVC, animated: true, completion: nil)
    }
    //ルーレットを開始
    @objc private func viewTapStart(tapGesture: UITapGestureRecognizer) {
        tapStartLabel.forEach { label in
            label.isHidden = true
        }
        quitButton.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.rouletteView.startRotateAnimation()
            self.rouletteView.rouletteSoundSetting()
        }
        view.removeGestureRecognizer(tapGesture)
    }
    //テキストの点滅
    private func blinkAnimation(labels: [UILabel]) {
        labels.forEach { label in
            UIView.transition(with: label, duration: 1.0, options: [.transitionCrossDissolve, .autoreverse, .repeat], animations: {
                label.layer.opacity = 0
            }) { _ in
                label.layer.opacity = 1
            }
        }
    }
    //ルーレットの針
    private func roulettePointerImage(w: CGFloat) -> UIImage {
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
        return image!
    }
    //ルーレットの真ん中のオブジェクト
    private func rouletteCenterCircleLabel(w: CGFloat) -> UILabel {
        let circleLabel = UILabel()
        circleLabel.bounds.size = CGSize(width: w, height: w)
        circleLabel.decoration(bgColor: .white)
        return circleLabel
    }
    //ルーレットの外側円線
    private func rouletteFrameCircle(w: CGFloat) -> UIView {
        let frameCircleView = UIView()
        frameCircleView.bounds.size = CGSize(width: w, height: w)
        frameCircleView.backgroundColor = .clear
        frameCircleView.layer.cornerRadius = frameCircleView.bounds.width / 2
        frameCircleView.layer.borderWidth = 2
        frameCircleView.layer.masksToBounds = true
        return frameCircleView
    }
}

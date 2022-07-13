//
//  RouletteViewController.swift
//  roulette
//
//  Created by USER on 2021/06/15.
//

import UIKit

protocol RouletteOutput: AnyObject {
    func addModule(addView: UIView)
    func hiddenModule()
    func rouletteDismiss()
}
class RouletteViewController: UIViewController {
    // MARK: Properties
    private var presenter: RouletteInput!

    // MARK: Outlets,Actions
    @IBOutlet var tapStartLabel: [UILabel]!
    @IBOutlet var quitButton: UIButton!
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        navigationController?.isNavigationBarHidden = true
        initialize()
        presenter.viewDidLoad()
        settingUI()
        settingGesture()
    }
    private func initialize() {
        presenter = RoulettePresenter(with: self)
    }
    private func settingUI() {
        quitButton.imageSet()
        tapStartLabel.forEach { lab in
            Animation.shared.blink(object: lab)
        }
    }
    private func settingGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(startGesture))
        view.addGestureRecognizer(gesture)
        quitButton.addTarget(self, action: #selector(quitGesture), for: .touchUpInside)
    }
    @objc private func startGesture(tapGesture: UITapGestureRecognizer) {
        presenter.rouletteStart()
        // gestureを削除してルーレットが回ってる時にタップできないようにする。
        view.removeGestureRecognizer(tapGesture)
    }
    @objc private func quitGesture() {
        AlertAppear(with: self).goBackHome()
    }
}
extension RouletteViewController: RouletteOutput {
    func addModule(addView: UIView) {
        let pointer = RouletteModule.shared.addPointer(point: view.center)
        let frameCircle = RouletteModule.shared.addFrameCircle(point: view.center)
        let centerCircle = RouletteModule.shared.addCenterCircle(point: view.center)
        [pointer, frameCircle, centerCircle].forEach { add in
            view.addSubview(add)
        }
        addView.center = view.center
        view.addSubview(addView)
        view.sendSubviewToBack(addView)
        view.bringSubviewToFront(pointer)
    }
    func hiddenModule() {
        tapStartLabel.forEach { label in
            label.isHidden = true
        }
        quitButton.isHidden = true
    }
    func rouletteDismiss() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapDismiss))
        view.addGestureRecognizer(gesture)
    }
    @objc private func tapDismiss() {
        print("tap")
        dismiss(animated: true)
    }
}

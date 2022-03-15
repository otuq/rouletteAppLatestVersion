//
//  RouletteViewController.swift
//  roulette
//
//  Created by USER on 2021/06/15.
//

import AVFoundation
import RealmSwift
import UIKit

protocol InterfaceInput: AnyObject {}
extension InterfaceInput {
    var d: CGFloat {
        let width = UIScreen.main.bounds.width
        let subtraction = (width / 13) / 2
        return (width - subtraction)
    }
     var w: CGFloat {
        CGFloat(30).recalcValue
    }
}

protocol RouletteOutput: AnyObject {
    func tapStart(complition: @escaping ([UILabel])->())
    func tapQuit(complition: @escaping (UIViewController)->())
}

class RouletteViewController: UIViewController {
    // MARK: Properties
    private var presenter: RoulettePresenter!
    private var gesture: UIGestureRecognizer!
    
    // MARK: Outlets,Actions
    @IBOutlet private var tapStartLabel: [UILabel]!
    @IBOutlet private var quitButton: UIButton!
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        navigationController?.isNavigationBarHidden = true
        initialize()
        settingUI()
        settingGesture()
        presenter.viewDidload()
    }
    private func initialize() {
        presenter = RoulettePresenter(with: self)
        view = presenter.rouletteView
    }
    private func settingUI() {
        quitButton.imageSet()
    }
    private func settingGesture() {
        gesture = UITapGestureRecognizer(target: self, action: #selector(startGesture))
        view.addGestureRecognizer(gesture)
        quitButton.addTarget(self, action: #selector(quitGesture), for: .touchUpInside)
    }
    @objc private func startGesture() {
        presenter.tapStart()
    }
    @objc private func quitGesture() {
        presenter.tapQuit()
    }
}
//MARK: -RouletteViewControllerExtension
extension RouletteViewController: RouletteOutput {
    func tapStart(complition: @escaping ([UILabel])->()) {
        complition(tapStartLabel)
        view.removeGestureRecognizer(gesture)
    }
    func tapQuit(complition: @escaping (UIViewController)->()){
        complition(self)
    }
}

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
    func hiddenLabel()
    var dataPresent: (dataSet: RouletteData, list: List<RouletteGraphData>) { get }
}

class RouletteViewController: UIViewController {
    // MARK: Properties
    private var presenter: RoulettePresenter!
    private var gesture: UIGestureRecognizer!
    
    // MARK: Outlets,Actions
    @IBOutlet private var tapStartLabel: [UILabel]!
    @IBOutlet private var quitButton: UIButton!
    
    var rouletteDataSet: (dataSet: RouletteData, list: List<RouletteGraphData>)!
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        navigationController?.isNavigationBarHidden = true
        initialize()
        settingUI()
        settingGesture()
    }
    private func initialize() {
        presenter = RoulettePresenter(with: self)
        
//        view.addSubview(rouletteView)
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
        presenter.rouletteStart()
    }
    @objc private func quitGesture() {
        AlertAppear.shared.appear(input: self)
    }
}
//MARK: -RouletteViewControllerExtension
extension RouletteViewController: RouletteOutput {
    var dataPresent: (dataSet: RouletteData, list: List<RouletteGraphData>) {
        rouletteDataSet
    }
    func hiddenLabel() {
        tapStartLabel.forEach { lab in
            lab.isHidden = true
        }
    }
}

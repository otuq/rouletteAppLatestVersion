//
//  RouletteViewController.swift
//  roulette
//
//  Created by USER on 2021/06/15.
//

import AVFoundation
import RealmSwift
import UIKit

protocol RouletteOutput: AnyObject, ShareProperty {
    var vc: UIViewController { get }
    var dataPresent: DataSet { get }
    func hiddenLabel()
}
class RouletteViewController: UIViewController {
    // MARK: Properties
    private var presenter: RouletteInput!
    private var gesture: UIGestureRecognizer!
    
    // MARK: Outlets,Actions
    @IBOutlet private var tapStartLabel: [UILabel]!
    @IBOutlet private var quitButton: UIButton!
    
    var rouletteDataSet: DataSet!
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
    }
    private func settingUI() {
        quitButton.imageSet()
        tapStartLabel.forEach { lab in
            Animation.shared.blink(object: lab)
        }
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
        AlertAppear.shared.suspension(vc: self)
    }
}
// MARK: - RouletteViewControllerExtension
extension RouletteViewController: RouletteOutput {
    var vc: UIViewController { self }
    var dataPresent: DataSet {
        rouletteDataSet
    }
    func hiddenLabel() {
        tapStartLabel.forEach { lab in
            lab.isHidden = true
        }
    }
}

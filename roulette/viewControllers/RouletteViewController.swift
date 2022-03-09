//
//  RouletteViewController.swift
//  roulette
//
//  Created by USER on 2021/06/15.
//

import AVFoundation
import RealmSwift
import UIKit

protocol InterfaceInput: AnyObject {
    var vc: RouletteViewController { get }
    var vw: CreateRouletteView { get }
    var bt: UIButton { get }
    var lbs: [UILabel] { get }
}
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
class RouletteViewController: UIViewController {
    // MARK: Properties
    private let rouletteView = CreateRouletteView()
    private var presenter: RoulettePresenter!

    var rouletteDataSet: (dataSet: RouletteData, list: List<RouletteGraphData>)! {
        didSet {
            guard rouletteDataSet != nil else { return print("detaSetがありません") }
            print(rouletteDataSet.dataSet.sound)
            rouletteView.rouletteDataSet = rouletteDataSet
        }
    }
    // MARK: Outlets,Actions
    @IBOutlet private var tapStartLabel: [UILabel]!
    @IBOutlet private var quitButton: UIButton!

    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        navigationController?.isNavigationBarHidden = true
        initializePresenter()
        presenter.viewDidload()
        settingGesture()
    }
    private func initializePresenter() {
        presenter = RoulettePresenter(with: self)
    }
    private func settingGesture() {
        let startTapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapStart))
        view.addGestureRecognizer(startTapGesture)
        quitButton.addTarget(self, action: #selector(quitTapDismiss), for: .touchUpInside)
    }
    // ルーレットを中止
    @objc private func quitTapDismiss() {
        presenter.alertAppear()
    }
    // ルーレットを開始
    @objc private func viewTapStart(tapGesture: UITapGestureRecognizer) {
        presenter.rouletteStart()
        view.removeGestureRecognizer(tapGesture)
    }
}
//MARK: -RouletteViewControllerExtension
extension RouletteViewController: InterfaceInput {
    var vc: RouletteViewController { self }
    var vw: CreateRouletteView { rouletteView }
    var bt: UIButton { quitButton }
    var lbs: [UILabel] { tapStartLabel }
}

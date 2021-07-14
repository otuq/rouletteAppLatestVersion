//
//  HomeViewController.swift
//  roulette
//
//  Created by USER on 2021/06/21.
//

import UIKit

class HomeViewController: UIViewController {
    //MARK:- Properties
    var dataSet: RouletteData?

    //MARK:-Outlets,Actions
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var setDataButton: UIButton!
    @IBOutlet weak var newDataButton: UIButton!
    @IBOutlet weak var rouletteTitleLabel: UILabel!
    @IBAction func appSettingButton(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "AppSetting", bundle: nil)
        let viewcontroller = storyboard.instantiateViewController(withIdentifier: "AppSettingViewController")
        let nav = UINavigationController.init(rootViewController: viewcontroller)
        nav.modalPresentationStyle = .overFullScreen
        present(nav, animated: true, completion: nil)
    }
    
    //MARK:-Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        settingGesture()
        settingAccesory()
    }
    private func settingGesture() {
        let startGesture = UITapGestureRecognizer(target: self, action: #selector(startGesture))
        let setGesture = UITapGestureRecognizer(target: self, action: #selector(setGesture))
        let newGesture = UITapGestureRecognizer(target: self, action: #selector(newGesture))

        startButton.addGestureRecognizer(startGesture)
        setDataButton.addGestureRecognizer(setGesture)
        newDataButton.addGestureRecognizer(newGesture)
        navigationController?.isNavigationBarHidden = true
    }
    @objc private func startGesture() {
        if dataSet != nil {
            let storyboard = UIStoryboard(name: "Roulette", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "RouletteViewController")
            let nav = UINavigationController(rootViewController: viewController)
            nav.modalPresentationStyle = .overFullScreen
            nav.modalTransitionStyle = .crossDissolve
            present(nav, animated: true, completion: nil)
        }
    }
    @objc private func setGesture() {
        let storyboard = UIStoryboard.init(name: "SetData", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "SetDataViewController")
        let nav = UINavigationController.init(rootViewController: viewController)
        nav.modalPresentationStyle = .overFullScreen
        present(nav, animated: true, completion: nil)
    }
    @objc private func newGesture() {
        let storyboard = UIStoryboard.init(name: "NewData", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "NewDataViewController")
        let nav = UINavigationController.init(rootViewController: viewController)
        nav.modalPresentationStyle = .overFullScreen
        present(nav, animated: true, completion: nil)
    }
    private func settingAccesory() {
        startButton.accesory()
    }
}



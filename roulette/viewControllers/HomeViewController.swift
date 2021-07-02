//
//  HomeViewController.swift
//  roulette
//
//  Created by USER on 2021/06/21.
//

import UIKit

class HomeViewController: UIViewController {
    
    //MARK:- Properties
    var dataSets: RouletteData?

    //MARK:-Outlets
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var setDataButton: UIButton!
    @IBOutlet weak var newDataButton: UIButton!
    
    //MARK:-Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        settingGesture()
        settingAccesory()
    }
    private func settingGesture() {
        let startGesture = UITapGestureRecognizer(target: self, action: #selector(startGesture))
        let editGesture = UITapGestureRecognizer(target: self, action: #selector(editGesture))
        let newGesture = UITapGestureRecognizer(target: self, action: #selector(newGesture))

        startButton.addGestureRecognizer(startGesture)
        setDataButton.addGestureRecognizer(editGesture)
        newDataButton.addGestureRecognizer(newGesture)
        navigationController?.isNavigationBarHidden = true
    }
    @objc private func startGesture() {
        if dataSets != nil {
            let storyboard = UIStoryboard(name: "Roulette", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "RouletteViewController")
            let nav = UINavigationController(rootViewController: viewController)
            nav.modalPresentationStyle = .overFullScreen
            nav.modalTransitionStyle = .crossDissolve
            present(nav, animated: true, completion: nil)
        }
    }
    
    @objc func editGesture() {
        
    }
    @objc func newGesture() {
        let storyboard = UIStoryboard.init(name: "NewData", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "NewDataViewController")
        let nav = UINavigationController.init(rootViewController: viewController)
        nav.modalPresentationStyle = .overFullScreen
        present(nav, animated: true, completion: nil)
    }
    private func settingAccesory() {
        startButton.accesory()
        setDataButton.accesory()
        newDataButton.accesory()
    }
}



//
//  Transition.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/21.
//

import UIKit

struct Transition {
    static let shared = Transition()
    typealias Append = () -> Void

    func modalPresent(parentVC: UIViewController, presentingVC: UIViewController?, presentation: UIModalPresentationStyle = .automatic, transition: UIModalTransitionStyle = .coverVertical, completion: Append? = nil ) {
        guard let presentingVC = presentingVC else { return }
        let nav = UINavigationController(rootViewController: presentingVC)
        nav.modalTransitionStyle = transition
        nav.modalPresentationStyle = presentation
        completion?()
        parentVC.present(nav, animated: true, completion: nil)
    }
}

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

    func modalPresent(vc: UIViewController?, presentation: UIModalPresentationStyle = .none, transition: UIModalTransitionStyle = .coverVertical, completion: Append? = nil ) {
        guard let vc = vc else { return }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalTransitionStyle = transition
        nav.modalPresentationStyle = presentation
        completion?()
        vc.parent?.present(nav, animated: true, completion: nil)
    }
}

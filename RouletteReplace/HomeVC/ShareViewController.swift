//
//  ShareViewController.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/23.
//

import UIKit

struct ShareViewController {
    static let shared = ShareViewController()
    
    func create() -> UIActivityViewController {
        let textString = "友人や家族にこのアプリを紹介しよう♪"
        //        let urlString = "https://apps.apple.com/jp/app/thee-roulette/id1602651709"
        let items = [textString, "URLないのよ〜"]
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return activityVC
    }
}

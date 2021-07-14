//
//  AppSettingViewController.swift
//  roulette
//
//  Created by USER on 2021/07/12.
//

import UIKit
import Eureka

class AppSettingViewController: FormViewController {
    //MARK:-properties
    private let userDefaults = UserDefaults.standard
    //MARK:-Outlets,Actions
    @IBAction func doneButton(_ sender: Any) {
        let formValues = form.values()
        userDefaults.set(formValues, forKey: "form")
        dismiss(animated: true, completion: nil)
    }
    //MARK:-Lifecyle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        settingView()
        settingForm()
    }
    
    private func settingView() {
        navigationController?.isNavigationBarHidden = false
    }
    private func settingForm() {
        let formValues = userDefaults.object(forKey: "form")as? [String: Any] ?? [:]
        form +++ Section("section1")
            //ルーレットの回るスピードを選択
            <<< SegmentedRow<String>("speed"){
                $0.options = ["slow","normal","fast"]
                $0.title = "speed"
                $0.value = formValues["speed"] as? Cell<String>.Value ?? $0.options?[0]
                for i in 0..<$0.cell.segmentedControl.numberOfSegments {
                    $0.cell.segmentedControl.widthForSegment(at: i)
                }
            }
            //ルーレットのドラムロール音を選択
            <<< PushRow<String>("sound"){
                $0.options = ["drumroll 1","drumroll 2","drumroll 3","drumroll 4"]
                $0.title = "sound"
                $0.value = formValues["sound"] as? Cell<String>.Value ?? $0.options?[0]
                $0.noValueDisplayText = $0.value
            }.onChange({ row in
                row.noValueDisplayText = row.value
            })
            //CustomCellにカスタムロウを定義。UIColorPickerVCでルーレットのテキストカラーを選択
            <<< CustomRow("colorPicker"){
                $0.title = "text color"
                let rgb = formValues["colorPicker"] as? [Int] ?? [0,255,255]
                $0.cell.colorLabel.backgroundColor = UIColor.init(r: rgb[0], g: rgb[1], b: rgb[2])
                $0.value = formValues["colorPicker"] as? Cell<[Int]>.Value ?? [0,255,255]
            }
    }
}

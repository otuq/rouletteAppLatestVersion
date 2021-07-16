//
//  AppSettingViewController.swift
//  roulette
//
//  Created by USER on 2021/07/12.
//

import UIKit
import Eureka

enum FormName: String {
    case speed, sound, colorPicker, formKey
}

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
                //segmentedControlの幅を変更
                $0.cell.segmentedControl.widthAnchor.constraint(equalToConstant: 200).isActive = true
                $0.value = formValues["speed"] as? Cell<String>.Value ?? $0.options?[0]
            }
            //ルーレットのドラムロール音を選択
            <<< PushRow<String>("sound"){
                $0.options = ["drumroll 1","drumroll 2","drumroll 3","drumroll 4"]
                $0.title = "sound"
                $0.value = formValues["sound"] as? Cell<String>.Value ?? $0.options?[0]
                $0.noValueDisplayText = $0.value
            }
            //CustomCellにカスタムロウを定義。UIColorPickerVCでルーレットのテキストカラーを選択
            <<< CustomRow("colorPicker"){
                let rgb = formValues["colorPicker"] as? [Int] ?? [0,255,255]
                let color = UIColor.init(r: rgb[0], g: rgb[1], b: rgb[2])
                $0.title = "text color"
                $0.cell.colorLabel.backgroundColor = color
                $0.cell.colorPickerVC.selectedColor = color
                $0.value = formValues["colorPicker"] as? Cell<[Int]>.Value ?? [0,255,255]
            }
    }
}

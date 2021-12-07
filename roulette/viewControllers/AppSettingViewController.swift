//
//  AppSettingViewController.swift
//  roulette
//
//  Created by USER on 2021/07/12.
//

import UIKit
import Eureka
import AVFoundation
import SafariServices

enum FormName: String {
    case speed, sound, colorPicker, formKey
}
enum Sound: String {
    case timpani, pop, funk, samba
}
enum Effect: String {
    case symbal, hits, conga, rhodes
}

class AppSettingViewController: FormViewController {
    //MARK: -properties
    private let userDefaults = UserDefaults.standard
    private var audioPlayer: AVAudioPlayer!
    
    //MARK: -Outlets,Actions
    @IBAction func doneButton(_ sender: Any) {
        let formValues = form.values()
        userDefaults.set(formValues, forKey: "form")
        statusBarStyleChange(style: .darkContent)
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: -Lifecyle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        settingView()
        settingForm()
    }
    private func settingView() {
        self.statusBarStyleChange(style: .lightContent)
        navigationController?.isNavigationBarHidden = false
    }
    private func soundSelect(soundString: String) {
        guard let soundAsset  = NSDataAsset(name: soundString) else {
            print("not found")
            return
        }
        do{
            audioPlayer = try AVAudioPlayer(data: soundAsset.data, fileTypeHint: "wav")
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }catch{
            print(error.localizedDescription)
            audioPlayer = nil
        }
    }
    private func settingForm() {
        let formValues = userDefaults.object(forKey: "form")as? [String: Any] ?? [:]
        form +++ Section("custom")
            //ルーレットの回るスピードを選択
            <<< SegmentedRow<String>("speed"){
                $0.options = ["slow","normal","fast"]
                $0.title = "speed"
                //segmentedControlの幅を変更
                $0.cell.segmentedControl.widthAnchor.constraint(equalToConstant: 200).isActive = true
                $0.value = formValues["speed"] as? Cell<String>.Value ?? $0.options?[1]
            }
            //ルーレットのドラムロール音を選択
            <<< PushRow<String>("sound"){
                $0.options = ["timpani","pop","funk","samba"]
                $0.title = "sound"
                $0.value = formValues["sound"] as? Cell<String>.Value ?? $0.options?[0]
                $0.noValueDisplayText = $0.value
            }.onPresent({ from, to in
                //デフォルトだとリストのセルを選択すると閉じるようになってる。
                to.dismissOnSelection = false
                to.dismissOnChange = false
                to.enableDeselection = false
                //selectorのカスタマイズ。selectableRowSetup、selectableRowCellUpdateおよびselectableRowCellSetupプロパティで選択可能なセルのカスタマイズが可能
                to.selectableRowCellUpdate = { _, row in
                    //選択されたリストの
                    row.onChange { row in
                        let value = Sound(rawValue: row.value ?? "")
                        switch value {
                        case .timpani:
                            self.soundSelect(soundString: value!.rawValue)
                        case .pop:
                            self.soundSelect(soundString: value!.rawValue)
                        case .funk:
                            self.soundSelect(soundString: value!.rawValue)
                        case .samba:
                            self.soundSelect(soundString: value!.rawValue)
                        case .none:
                            break
                        }
                    }
                }
            })
            //ルーレットの効果音を選択
            <<< PushRow<String>("effect"){
                $0.options = ["symbal","hits","conga","rhodes"]
                $0.title = "effect"
                $0.value = formValues["effect"] as? Cell<String>.Value ?? $0.options?[0]
                $0.noValueDisplayText = $0.value
            }.onPresent({ from, to in
                //デフォルトだとリストのセルを選択すると閉じるようになってる。
                to.dismissOnSelection = false
                to.dismissOnChange = false
                to.enableDeselection = false
                //selectorのカスタマイズ。selectableRowSetup、selectableRowCellUpdateおよびselectableRowCellSetupプロパティで選択可能なセルのカスタマイズが可能
                to.selectableRowCellUpdate = { _, row in
                    //選択されたリストが列挙で指定した値と一致したらsoundSelectメソッドを発火
                    row.onChange { row in //cellUpdateだとカラーピッカーを閉じた後PushRowから遷移するだけでsoundSelectメソッドまで読み込まれてしまうバグがあってハマった。
                        let value = Effect(rawValue: row.value ?? "")
                        switch value {
                        case .symbal:
                            self.soundSelect(soundString: value!.rawValue)
                        case .hits:
                            self.soundSelect(soundString: value!.rawValue)
                        case .conga:
                            self.soundSelect(soundString: value!.rawValue)
                        case .rhodes:
                            self.soundSelect(soundString: value!.rawValue)
                        case .none:
                            break
                        }
                    }
                }
            })
            //CustomCellにカスタムロウを定義。UIColorPickerVCでルーレットのテキストカラーを選択
            <<< CustomRow("colorPicker"){
                let rgb = formValues["colorPicker"] as? [Int] ?? [0,0,0]
                let color = UIColor.init(r: rgb[0], g: rgb[1], b: rgb[2])
                $0.title = "text color"
                $0.cell.colorLabel.backgroundColor = color
                $0.cell.colorPickerVC.selectedColor = color
                $0.value = formValues["colorPicker"] as? Cell<[Int]>.Value ?? [0,0,0]
            }
        //現在のversion
        form +++ Section("information")
            //プライバシー情報のwebページに遷移
            <<< ButtonRow(){
                $0.title = "privacy"
                $0.presentationMode = .presentModally(controllerProvider: ControllerProvider.callback(builder: {
                    if let url = URL(string: "https://otuq.github.io/"){
                        let safariVC = SFSafariViewController(url: url)
                        return safariVC
                    }
                    return UIViewController()
                }), onDismiss: nil)
            }
            //Twitter
            <<< ButtonRow(){
                $0.title = "twitter"
                $0.cellStyle = .value1 //初期ではセルが中央揃えのtintColorがblueに設定してあるので左揃えになるスタイルに変更
            }.cellUpdate { cell, row in
                //このコールバック関数内にアクセサリーの設定を他のセルのスタイルに合わせる。
                cell.tintColor = UIColor.dynamicColor(light: .black, dark: .white)
                cell.accessoryType = .disclosureIndicator
            }.onCellSelection { _, _ in
                if let url = URL(string: "https://twitter.com/OPQR64013140"){
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            //version情報
            <<< TextRow("version"){
                $0.title = "version"
                $0.value = "1.0"
                $0.cell.isUserInteractionEnabled = false
            }
    }
}

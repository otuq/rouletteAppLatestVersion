//
//  AppSettingViewController.swift
//  roulette
//
//  Created by USER on 2021/07/12.
//

import AVFoundation
import Eureka
import SafariServices
import UIKit

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
    // MARK: Properties
    private let userDefaults = UserDefaults.standard
    private let formRows = FormRows()

    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        settingView()
        settingForm()
    }
    private func settingView() {
        self.statusBarStyleChange(style: .lightContent)
        navigationController?.isNavigationBarHidden = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneBarButton))
    }
    @objc private func doneBarButton() {
        let formValues = form.values()
        userDefaults.set(formValues, forKey: "form")
        statusBarStyleChange(style: .darkContent)
        dismiss(animated: true, completion: nil)
    }
    private func settingForm() {
        let formValues = userDefaults.object(forKey: "form")as? [String: Any] ?? [:]
        form +++ Section("custom")
            <<< formRows.speedSelectRow(formValues)
            <<< formRows.drumRoloSelectRow(formValues)
            <<< formRows.effectSelectRow(formValues)
            <<< formRows.textColorSelectRow(formValues)
        form +++ Section("information")
            <<< formRows.privacyPolicyRow(formValues)
            <<< formRows.twitterRow(formValues)
            <<< formRows.versionRow(formValues)
    }
}

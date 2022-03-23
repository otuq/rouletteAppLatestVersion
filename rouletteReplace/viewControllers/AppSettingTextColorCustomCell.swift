//
//  CustomCell.swift
//  roulette
//
//  Created by USER on 2021/07/14.
//

import Eureka
import UIKit

class AppSettingTextColorCustomCell: Cell<[Int]>, CellType, UIColorPickerViewControllerDelegate {
    // MARK: Properties
    let colorPickerVC = UIColorPickerViewController()

    // MARK: Outletes,acitons
    @IBOutlet var colorLabel: UILabel!

    // MARK: Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.settingUI()
        }
    }
    override func didSelect() {
        colorPickerVC.delegate = self
        formViewController()?.present(colorPickerVC, animated: true, completion: nil)
    }
    private func settingUI() {
        colorLabel.layer.cornerRadius = colorLabel.bounds.width / 2
        colorLabel.layer.masksToBounds = true
        colorLabel.layer.borderWidth = 0.5
        colorLabel.layer.borderColor = UIColor.label.cgColor
    }
    //    UIColorPickerVCを閉じた時
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
        colorLabel.backgroundColor = color
        row.value = [color.r, color.g, color.b]
        row.deselect(animated: true)
    }
}
// MARK: - CustomRow
// CustomCellをセットする
final class CustomRow: SelectorRow<AppSettingTextColorCustomCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<AppSettingTextColorCustomCell>(nibName: "AppSettingTextColorCustomCell")
    }
}

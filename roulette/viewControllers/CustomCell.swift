//
//  CustomCell.swift
//  roulette
//
//  Created by USER on 2021/07/14.
//

import UIKit
import Eureka

class CustomCell: Cell<[Int]>, CellType, UIColorPickerViewControllerDelegate {
    let colorPickerVC = UIColorPickerViewController()
    @IBOutlet weak var colorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        colorLabel.layer.cornerRadius = colorLabel.bounds.width / 2
        colorLabel.layer.masksToBounds = true
        colorLabel.layer.borderWidth = 0.5
        colorLabel.layer.borderColor = UIColor.label.cgColor
    }
    override func didSelect() {
        colorPickerVC.delegate = self
        formViewController()?.present(colorPickerVC, animated: true, completion: nil)
    }
    //    UIColorPickerVCを閉じた時
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
        colorLabel.backgroundColor = color
        row.value = [color.r, color.g, color.b]
        row.deselect(animated: true)
    }
}
//CustomCellをセットする
final class CustomRow: SelectorRow<CustomCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<CustomCell>(nibName: "CustomCell")
    }
}

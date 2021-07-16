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
    }
    override func setup() {
        super.setup()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(presentColorPicker))
        self.addGestureRecognizer(gesture)
    }
    @objc func presentColorPicker() {
        colorPickerVC.delegate = self
        parentViewController?.present(colorPickerVC, animated: true, completion: nil)
    }
    //UIColorPickerVCを閉じた時
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
        colorLabel.backgroundColor = color
        row.value = [color.r, color.g, color.b]
    }
    //値が変わった時
//    override func update() {
//        <#code#>
//    }
}
//CustomCellをセットする
final class CustomRow: Row<CustomCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<CustomCell>(nibName: "CustomCell")
    }
}

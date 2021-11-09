//
//  CollectionViewCell.swift
//  roulette
//
//  Created by USER on 2021/06/23.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    //MARK:-properties
    var color: UIColor? {
        didSet{
            colorSelect.backgroundColor = color ?? .white
        }
    }
    
    //MARK:-Outlets,Actions
    @IBOutlet weak var colorSelect: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
    //MARK:-Lifecyle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.settingUI()
        }
    }
    
    private func settingUI() {
        colorSelect.layer.cornerRadius = colorSelect.bounds.width / 2
        colorSelect.layer.masksToBounds = true
        bringSubviewToFront(checkImageView)
    }
}

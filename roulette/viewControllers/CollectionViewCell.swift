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
    
    //MARK:-Lifecyle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        colorSelect.layer.cornerRadius = colorSelect.bounds.width / 2
        colorSelect.layer.masksToBounds = true
    }
}

//
//  ColorsSelectViewController.swift
//  roulette
//
//  Created by USER on 2021/06/23.
//

import UIKit

class ColorSelectViewController: UIViewController {
    // MARK: properties
    private let cellId = "cellId"
    private let currentColor: UIColor?
    private let cellIndex: Int?
    private let colors: [UIColor] = {
        var colors = [UIColor]()
        stride(from: 0, to: 360, by: 18).forEach { i in
            let color = UIColor.hsvToRgb(h: Float(i), s: 128, v: 255)
            colors.append(color)
        }
        return colors
    }()
    // MARK: Outlets,Actions
    @IBOutlet var colorSelectCollectionView: UICollectionView!
    
    // MARK: Methods
    init?(coder: NSCoder, currentColor: UIColor?, cellIndex: Int?) {
        self.currentColor = currentColor
        self.cellIndex = cellIndex
        super.init(coder: coder)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        settingView()
    }
    private func settingView() {
        colorSelectCollectionView.delegate = self
        colorSelectCollectionView.dataSource = self
        colorSelectCollectionView.register(UINib(nibName: R.nib.colorSelectCollectionViewCell.name, bundle: nil), forCellWithReuseIdentifier: cellId)
    }
}
// MARK: - CollectionViewDelegate,Datasource
extension ColorSelectViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        colors.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)as! CollectionViewCell
        cell.color = colors[indexPath.row]
        // 色のチェックマーク
        if currentColor == colors[indexPath.row] {
            cell.checkImageView.isHidden = false
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let colum: CGFloat = 5
        let row = CGFloat(colors.count) / colum
        return CGSize(width: view.frame.width / colum, height: view.frame.height / row)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        .zero
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        .zero
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // UIColorをextensionしてUIColorからrgb値を取得してデータを保存。realmはUIColorを準拠していないみたいでUIColorの保存ができないみたい。
        guard let nav = presentingViewController as? UINavigationController,
              let newDataVC = nav.viewControllers[nav.viewControllers.count - 1]as? NewDataViewController,
              let cellIndex = cellIndex else { return }
        let temporary = newDataVC.graphTemporary(index: cellIndex)
        temporary.rgbTemporary["r"] = colors[indexPath.row].r
        temporary.rgbTemporary["g"] = colors[indexPath.row].g
        temporary.rgbTemporary["b"] = colors[indexPath.row].b
        newDataVC.newDataTableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
}

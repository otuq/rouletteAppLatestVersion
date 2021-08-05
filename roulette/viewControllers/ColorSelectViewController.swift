//
//  ColorsSelectViewController.swift
//  roulette
//
//  Created by USER on 2021/06/23.
//

import UIKit
import RealmSwift

class ColorSelectViewController: UIViewController {
    //MARK:-properties
    private let cellId = "cellId"
    private let colors: [UIColor] = [.blue,.red,.yellow,.green,.purple,.brown,.cyan,.magenta,.orange,.paleBlue,.paleRed,.yellowGreen]
    var cellTag: Int? //変数以外でindex番号格納できないか？
    
    //MARK:-Outlets,Actions
    @IBOutlet weak var colorSelectCollectionView: UICollectionView!
    
    //MARK:-Lifecyle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        settingView()
    }
    private func settingView() {
        colorSelectCollectionView.delegate = self
        colorSelectCollectionView.dataSource = self
        colorSelectCollectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: cellId)
    }
}
//MARK:- CollectionViewDelegate,Datasource
extension ColorSelectViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        colors.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)as! CollectionViewCell
        cell.color = colors[indexPath.row]
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let colum: CGFloat = 5
        let row: CGFloat = CGFloat(colors.count) / colum
        
        return CGSize(width: view.frame.width / colum, height: (view.frame.height / row) / 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //カラーを選択したらindexPath.rowの番号とcolorsのインデックス番号をtableViewに渡して更新する。
        guard let nav = presentingViewController as? UINavigationController,
              let newDataVC = nav.viewControllers[nav.viewControllers.count - 1]as? NewDataViewController else { return }
        if let cellTag = cellTag {
            //UIColorをextensionしてUIColorからrgb値を取得してデータを保存。realmはUIColorを準拠していないみたいでUIColorの保存ができないみたい。
            let rgbTemporary = newDataVC.dataSet.temporarys[cellTag]
            rgbTemporary.rgbTemporary["r"] = colors[indexPath.row].r
            rgbTemporary.rgbTemporary["g"] = colors[indexPath.row].g
            rgbTemporary.rgbTemporary["b"] = colors[indexPath.row].b
            newDataVC.newDataTableView.reloadData()
            dismiss(animated: true, completion: nil)
        }
    }
}

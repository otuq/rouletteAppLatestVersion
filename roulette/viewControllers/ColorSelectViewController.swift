//
//  ColorsSelectViewController.swift
//  roulette
//
//  Created by USER on 2021/06/23.
//

import UIKit

class ColorSelectViewController: UIViewController {
    
    //MARK:-properties
    private let cellId = "cellId"
    private let colors: [UIColor] = [.blue,.red,.yellow,.green,.cyan,.purple]
    var cellTag: Int? //変数以外でindex番号格納できないか？
    
    //MARK:-Outlets
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
        let row: CGFloat = 2
        
        return CGSize(width: collectionView.bounds.width / colum, height: collectionView.bounds.height / row)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //カラーを選択したらindexPath.rowの番号とcolorsのインデックス番号をtableViewに渡して更新する。
        guard let nav = presentingViewController as? UINavigationController,
              let newDataVC = nav.viewControllers[nav.viewControllers.count - 1]as? NewDataViewController else { return }
        if let cellTag = cellTag {
            newDataVC.dataSets[cellTag].color = colors[indexPath.row]
            newDataVC.newDataTableView.reloadData()
            dismiss(animated: true, completion: nil)
        }
    }
}

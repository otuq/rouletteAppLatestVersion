//
//  TableViewCell.swift
//  roulette
//
//  Created by USER on 2021/06/21.
//

import UIKit

class TableViewCell: UITableViewCell, UIViewControllerTransitioningDelegate, UITextFieldDelegate {
    //MARK:-properties
    private let selectView = UIView()
    var graphDataTemporary: RouletteGraphTemporary? {
        didSet{
            guard let temporary = graphDataTemporary else { return }
            let rgb = temporary.rgbTemporary
            let text = temporary.textTemporary
            rouletteSetColor.backgroundColor = UIColor.init(r: rgb["r"]!, g: rgb["g"]!, b: rgb["b"]!)
            rouletteTextView.text = text
        }
    }
    
    //MARK:-Outlets,Actions
    @IBOutlet weak var rouletteSetColor: UILabel!
    @IBOutlet weak var rouletteTextView: UITextField!
    
    //MARK:-LifeCycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(selectColorViewFetch))
        selectView.backgroundColor = .clear
        selectedBackgroundView = selectView
        rouletteTextView.delegate = self
        
        rouletteSetColor.layer.cornerRadius = rouletteSetColor.bounds.width / 2
        rouletteSetColor.layer.masksToBounds = true
        rouletteSetColor.addGestureRecognizer(gesture)
        rouletteSetColor.isUserInteractionEnabled = true
        rouletteTextView.isUserInteractionEnabled = true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let newDataVC = parentViewController as? NewDataViewController,
              let cellIndexPath = newDataVC.newDataTableView.indexPath(for: self) else { return }
        let row = cellIndexPath.row
        newDataVC.dataSet.temporarys[row].textTemporary = textField.text ?? ""
        
    }
    @objc func selectColorViewFetch() {
        let storyboard = UIStoryboard(name: "ColorSelect", bundle: nil)
        let colorSelectVC = storyboard.instantiateViewController(withIdentifier: "ColorSelectViewController")as! ColorSelectViewController
        //PresentationControllerをカスタマイズして色選択のモーダルウィンドウを作成
        colorSelectVC.transitioningDelegate = self
        colorSelectVC.modalPresentationStyle = .custom
        //色のラベルをタップした時にタップされたセルのindex番号を取得する。セルをタップした場合はindexPathSelectRowを使うがラベルにタップした時には検出されないので下記のコードで取得する。
        guard let newDataVC = parentViewController as? NewDataViewController,
              let cellIndexPath = newDataVC.newDataTableView.indexPath(for: self) else { return }
        //cellのindex番号を遷移先のVCに渡す
        colorSelectVC.cellTag = cellIndexPath.row
        //親ViewControllerを取得　extensionにて
        parentViewController?.present(colorSelectVC, animated: true, completion: nil)
    }
    //PresentationControllerをカスタムするためのdelegateメソッド
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        ColorsSelectPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

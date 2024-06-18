//
//  EditCategoryView.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 04/06/2024.
//

import UIKit

class EditCategoryView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var editCategoryCollectionView: UICollectionView!
    @IBOutlet weak var addCategoryButton: UIButton!
    
    override init(frame:CGRect){
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }
    func loadNib(){
        Bundle.main.loadNibNamed("EditCategoryView", owner: self,options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}

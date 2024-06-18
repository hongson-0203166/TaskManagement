//
//  EditPriorityView.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 04/06/2024.
//

import UIKit

class EditPriorityView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var editTaskPriorityCollectionView: UICollectionView!
    @IBOutlet weak var cancelTaskPriorityButton: UIButton!
    @IBOutlet weak var editTaskPriorityButton: UIButton!
    
    override init(frame:CGRect){
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }
    func loadNib(){
        Bundle.main.loadNibNamed("EditPriorityView", owner: self,options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}

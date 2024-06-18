//
//  DeleteTaskView.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 03/06/2024.
//

import UIKit

class DeleteTaskView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleTaskLable: UILabel!
    @IBOutlet weak var cancelDeleteButton: UIButton!
    @IBOutlet weak var accecptDeleteButton: UIButton!
    
    
    override init(frame:CGRect){
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }
    func loadNib(){
        Bundle.main.loadNibNamed("DeleteTaskView", owner: self,options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}

//
//  EditTaskTitleView.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 03/06/2024.
//

import UIKit

class EditTaskTitleView: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var editTitleTextField: UITextField!
    
    @IBOutlet weak var editDescriptionTextField: UITextField!
    
    @IBOutlet weak var cancelEditTitleButton: UIButton!
    @IBOutlet weak var editTitleButton: UIButton!
    
    override init(frame:CGRect){
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }
    func loadNib(){
        Bundle.main.loadNibNamed("EditTaskTitleView", owner: self,options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}

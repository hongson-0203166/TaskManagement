//
//  EditTaskHeaderView.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 02/06/2024.
//

import UIKit

class EditTaskHeaderView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleTaskLable: UILabel!
    @IBOutlet weak var descriptionTaskLable: UILabel!
    @IBOutlet weak var editTitleAndDesButton: UIButton!
    @IBOutlet weak var todoOrDoneButton: UIButton!
    @IBOutlet weak var dissmissButton: UIButton!
    @IBOutlet weak var editReloadButton: UIButton!
    
    override init(frame:CGRect){
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }
    func loadNib(){
        Bundle.main.loadNibNamed("EditTaskHeaderView", owner: self,options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}

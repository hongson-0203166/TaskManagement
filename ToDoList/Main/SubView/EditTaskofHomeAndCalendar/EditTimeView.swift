//
//  EditTimeView.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 04/06/2024.
//

import UIKit

class EditTimeView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var timeOfDatePiker: UIDatePicker!
    @IBOutlet weak var cancelChooseTime: UIButton!
    @IBOutlet weak var editChooseTime: UIButton!
    
    override init(frame:CGRect){
        super.init(frame: frame)
        loadNib()
        timeOfDatePiker.setValue(UIColor(hexString: "544F61"), forKeyPath: "textColor")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
        timeOfDatePiker.setValue(UIColor(hexString: "544F61"), forKeyPath: "textColor")
    }
    func loadNib(){
        Bundle.main.loadNibNamed("EditTimeView", owner: self,options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

}

//
//  HeaderCalendarUIView.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 06/06/2024.
//

import UIKit

class HeaderViewForCalendar: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var completedButton: UIButton!
    
    
    override init(frame:CGRect){
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        loadNib()
    }
    func loadNib(){
  
        
        Bundle.main.loadNibNamed("HeaderViewForCalendar", owner: self,options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}

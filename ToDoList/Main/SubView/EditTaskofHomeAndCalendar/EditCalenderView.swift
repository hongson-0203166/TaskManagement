//
//  EditCalenderView.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 04/06/2024.
//

import UIKit

class EditCalenderView: UIView {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var previousMonthButton: UIButton!
    @IBOutlet weak var nextMonthButton: UIButton!
    @IBOutlet weak  var monthAndYearButton: UIButton!
    @IBOutlet weak var daysStackView: UIStackView!
    @IBOutlet weak  var calendarCV: UICollectionView!
    @IBOutlet weak var datePickerView: UIPickerView!
    @IBOutlet weak var monthTitleLable: UILabel!
    @IBOutlet weak var yearTitleLable: UILabel!
    @IBOutlet weak var chooseTimeButton: UIButton!
    @IBOutlet weak var inventoryView: UIView!
    @IBOutlet weak var cancelEditTimeButton: UIButton!
    

    
    
    override init(frame:CGRect){
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }
    func loadNib(){
        Bundle.main.loadNibNamed("EditCalenderView", owner: self,options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}

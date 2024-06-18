//
//  CalendarOfDayCollectionViewCell.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 05/06/2024.
//

import UIKit

class CalendarOfDayCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var backgroundUIView: UIView!
    @IBOutlet weak var dayNumberLabel: UILabel!
    @IBOutlet weak var dotView: UIView!
    
    @IBOutlet weak var weekdayLable: UILabel!
    
    func setup(_ calendarDate: CalendarDate, selected: Bool) {
        backgroundUIView.layer.cornerRadius = 6
        backgroundUIView.layer.masksToBounds = true
        dotView.layer.cornerRadius = 3
        dotView.layer.masksToBounds = true
        let blueColor = UIColor(named: "BlueColor") ?? UIColor.blue
        let lightBlueColor = UIColor(named: "LightBlueColor") ?? UIColor.systemBlue
        let today = calendarDate.date.isEqual(Date.now)

        let available = calendarDate.available && calendarDate.calendarMonth == .Current
        
        
        let purpleColor = UIColor(hexString: "8687E7")
        dayNumberLabel.text = String(calendarDate.date.day())
        let textColor = selected ? today ? UIColor.white : blueColor : today ? blueColor : available ? UIColor(hexString: "272727") : .clear
        
        let backgroundColor = selected ? today ? purpleColor : UIColor(hexString: "9F86E7") : today ? purpleColor : available ? UIColor(hexString: "272727") : .clear
        dayNumberLabel.textColor = .white
        
        backgroundUIView.backgroundColor = backgroundColor
        
       // dayNumberLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    }
}

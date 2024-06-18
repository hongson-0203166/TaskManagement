//
//  Extension + UIDatePicker.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 16/05/2024.
//


import UIKit

extension UIDatePicker {
    func setPickerTextColor(_ color: UIColor) {
            let attributes = [NSAttributedString.Key.foregroundColor: color]
            let attributedString = NSAttributedString(string: "1", attributes: attributes)
            setValue(attributedString, forKeyPath: "textColor")
        }
    func showOnlyCurrentSelection() {
        setValue(false, forKey: "highlightsToday")
    }
    
    func showOnlySingleDigit() {
        setValue(false, forKey: "showSingleWheelValue")
    }
}

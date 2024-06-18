//
//  TaskTableViewCell.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 27/05/2024.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    @IBOutlet weak var flag: UIView!
    
    @IBOutlet weak var imageandLableView: UIView!
    
    @IBOutlet weak var contView: UIView!
    
    @IBOutlet weak var flagNumberLable: UILabel!
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var titleTask: UILabel!
    @IBOutlet weak var dateLable: UILabel!
    @IBOutlet weak var eventCompleteTask: UIImageView!
    
    @IBOutlet weak var imageStatus: UIImageView!
    
    
    var buttonAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        flag.layer.cornerRadius = 4
        flag.layer.masksToBounds = true
        flag.layer.borderColor = UIColor(hexString: "8687E7")?.cgColor
        flag.layer.borderWidth = 1
        imageandLableView.layer.cornerRadius = 4
        imageandLableView.layer.masksToBounds = true
        
        contView.layer.cornerRadius = 4
        contView.layer.masksToBounds = true
       
    }
    
    @IBAction func actionHandle(_ sender: Any) {
        buttonAction?()
    }
}

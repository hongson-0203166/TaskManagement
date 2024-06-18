//
//  EditTaskTableViewCell.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 02/06/2024.
//

import UIKit

class EditTaskTableViewCell: UITableViewCell {
    @IBOutlet weak var iconofTask: UIImageView!
    @IBOutlet weak var lableofEditTask: UILabel!
    @IBOutlet weak var viewforButtonTask: UIView!
    @IBOutlet weak var categoryIconImage: UIImageView!
    @IBOutlet weak var categoryLable: UILabel!
    @IBOutlet weak var editOfFieldButton: UIButton!
    var completion: (()->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewforButtonTask.layer.cornerRadius = 6
        viewforButtonTask.layer.masksToBounds = true
        editOfFieldButton.addTarget(self, action: #selector(editCell), for: .touchUpInside)
    }
    @objc func editCell(){
        self.completion?()
    }
    
    
    func configureUIforCell(iconOfTask: String,lableOfEditTask: String, cateGoryLable:String, categoryIcoYImage:String){
        iconofTask.image = UIImage(named: iconOfTask)
        lableofEditTask.text = lableOfEditTask
        categoryLable.text = cateGoryLable
        categoryIconImage.image = UIImage(named: categoryIcoYImage)
        
        if categoryIconImage.image == UIImage(named: ""){
            categoryIconImage.isHidden == true
        }
       
    }
    
    
    

  
    
}

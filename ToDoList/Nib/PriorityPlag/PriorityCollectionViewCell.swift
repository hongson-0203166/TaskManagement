//
//  PriorityCollectionViewCell.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 16/05/2024.
//

import UIKit

class PriorityCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var priorityLable: UILabel!
   
    @IBOutlet weak var priorityView: UIView!
   
    
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    func setup(indexPath: IndexPath){
        priorityLable.text = "\(indexPath.row + 1)"
        priorityView.layer.cornerRadius = 4
        priorityView.layer.masksToBounds = true
    }

 
}

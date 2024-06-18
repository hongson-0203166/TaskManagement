//
//  ColorCollectionViewCell.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 21/05/2024.
//

import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var chooseColor: UIImageView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupUI(color: String){
        colorView.backgroundColor = UIColor(hexString: color)
        colorView.layer.cornerRadius = 18
        colorView.layer.masksToBounds = true
    }

}

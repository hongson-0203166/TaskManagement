//
//  CategoryCollectionViewCell.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 20/05/2024.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var CategoryImageView: UIImageView!
    @IBOutlet weak var categoryNameLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        CategoryImageView.layer.cornerRadius = 4
        CategoryImageView.layer.masksToBounds = true
    }
    
    func setupUI(nameCategory: String, categoryImage: String, categoryColor: String){
        CategoryImageView.image = UIImage(named: categoryImage)
        CategoryImageView.backgroundColor = UIColor(hexString: categoryColor)
        categoryNameLable.text = nameCategory
    }
}

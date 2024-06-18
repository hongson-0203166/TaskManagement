//
//  HeaderProfileView.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 06/06/2024.
//

import UIKit

class HeaderProfileView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var fullNameProfile: UILabel!
    override init(frame:CGRect){
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }
    func loadNib(){
        Bundle.main.loadNibNamed("HeaderProfileView", owner: self,options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}

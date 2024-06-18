//
//  Extension + Tabbar.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 14/06/2024.
//


import UIKit
extension UITabBarController{

    func getHeight()->CGFloat{
        return self.tabBar.frame.size.height
    }

    func getWidth()->CGFloat{
         return self.tabBar.frame.size.width
    }
}

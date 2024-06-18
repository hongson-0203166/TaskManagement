//
//  CustomTabBarController.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 08/05/2024.
//


import UIKit
import SwiftHEXColors


class CustomTabBarController: UITabBarController,BlurVCDelegate {
   
    func removeBlurView() {
        print("removeBlurView")
        for subview in view.subviews {
                    if subview.isKind(of: UIVisualEffectView.self) {
                        subview.removeFromSuperview()
                    }
                }
    }
    
 
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.isTranslucent = false
        //tabBar.tintColor = UIColor(hexString: "FFFFFF")
        tabBar.backgroundColor = UIColor(hexString: "363636")
        tabBar.tintColor = UIColor.white
        UITabBar.appearance().tintColor = UIColor.white
        UITabBar.appearance().unselectedItemTintColor = .lightGray
    
         delegate = self
        
        
        // Instantiate view controllers
        let homeNav = self.storyboard?.instantiateViewController(withIdentifier: "HomeNav") as! UINavigationController
        
        let calendarNav = self.storyboard?.instantiateViewController(withIdentifier: "CalendarNav") as! UINavigationController
        
        let newPostVC = self.storyboard?.instantiateViewController(withIdentifier: "NewPostViewController") as! UIViewController
        
        
//        NewPostViewController
        let FocusNav = self.storyboard?.instantiateViewController(withIdentifier: "FocusNav") as! UINavigationController
        
        let profiletNav = self.storyboard?.instantiateViewController(withIdentifier: "ProfileNav") as! UINavigationController
        
        
        // Create TabBar items
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "home"), selectedImage: UIImage(named: "home"))
        
        calendarNav.tabBarItem = UITabBarItem(title: "Calendar", image: UIImage(named: "calendar"), selectedImage: UIImage(named: "calendar"))
        
        newPostVC.tabBarItem = UITabBarItem(title: nil, image: nil, selectedImage: nil)
        
        FocusNav.tabBarItem = UITabBarItem(title: "Notifications", image: UIImage(systemName: "bell"), selectedImage: UIImage(systemName: "bell"))
        
        profiletNav.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "user"), selectedImage: UIImage(named: "user"))
        
        
        // Assign viewControllers to tabBarController
        let viewControllers = [homeNav, calendarNav, newPostVC, FocusNav, profiletNav]
        self.setViewControllers(viewControllers, animated: false)
        
        
        guard let tabBar = self.tabBar as? CustomTabBar else { return }
        
        tabBar.didTapButton = { [unowned self] in
            self.routeToCreateNewAd()
        }
    }
    
    func routeToCreateNewAd() {
        // Instantiate newPostVC
            let newPostVC = storyboard?.instantiateViewController(withIdentifier: "NewPostViewController") as? NewPostViewController
        newPostVC?.modalPresentationStyle = .custom
        present(newPostVC ?? UIViewController(), animated: true, completion: nil)
            
            setBlurView()
        newPostVC?.delegatee = self
    }
    
    func setBlurView() {
            
        // Tạo một UIBlurEffect với các thuộc tính tùy chỉnh
        let customBlurEffect = UIBlurEffect(style: .systemChromeMaterialDark)
              if let blurEffectView = UIVisualEffectView(effect: customBlurEffect) as? UIVisualEffectView {

                  // Điều chỉnh các thuộc tính của hiệu ứng làm mờ
                  blurEffectView.alpha = 0.9 // Độ mờ
                 
                  // Thêm blurEffectView vào view hierarchy
                  view.addSubview(blurEffectView)
                  blurEffectView.translatesAutoresizingMaskIntoConstraints = false

                  // Thiết lập các constraints cho blurEffectView
                  NSLayoutConstraint.activate([
                      blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                      blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                      blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
                      blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                  ])
              }
        }
}

// MARK: - UITabBarController Delegate
extension CustomTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController) else {
            return true
        }
        // Your middle tab bar item index.
        // In my case it's 1.
        if selectedIndex == 2 {
            return false
        }
        
        return true
    }
}



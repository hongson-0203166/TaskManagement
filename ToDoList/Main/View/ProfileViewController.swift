//
//  ProfileViewController.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 08/05/2024.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var section = ["Settings", "Account", "Uptodo"]
    var imageProfile = [
                                        0: ["setting-2"] ,
                                        1: ["user", "key 1", "camera"],
                                        2: ["menu 1", "info-circle", "flash", "like", "logout"]
                            ]
    
    var contenProfile = [
                                        0: ["App Settings"] ,
                                        1: ["Change account name", "Change account password", "Change account Image"],
                                        2: ["About US", "FAQ", "Help & Feedback", "Support US", "Log out"]
                            ]
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Profile"
        tableView.register(UINib(nibName: "ProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "ProfileTableViewCell")
        self.navigationController?.isNavigationBarHidden = true
    }
}
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return section.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0: return 1
        case 1 :return 3
        case 2: return 5
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell") as! ProfileTableViewCell
            cell.backgroundColor = .clear
        cell.selectionStyle = .none
        let section = indexPath.section
        let row = indexPath.row
        
        cell.contentLable.text = contenProfile[section]?[row]
        if let imageName = imageProfile[section]?[row] {
            cell.rightImage.image = UIImage(named: imageName)
               }
        return cell
    }
    
    // Tùy chỉnh tiêu đề cho header của section
      func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
          let headerView = UIView()
          headerView.backgroundColor = .clear
          
          let label = UILabel()
          label.text = self.section[section]
          label.textColor = UIColor(hexString: "AFAFAF")
          label.font = UIFont.boldSystemFont(ofSize: 16)
          
          headerView.addSubview(label)
          
          label.translatesAutoresizingMaskIntoConstraints = false
          NSLayoutConstraint.activate([
              label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
              label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
              label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
              label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
          ])
          
          return headerView
      }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

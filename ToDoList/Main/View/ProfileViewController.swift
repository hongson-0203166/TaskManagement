//
//  ProfileViewController.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 08/05/2024.
//

import UIKit
import SnapKit
import Kingfisher
import FirebaseAuth
import GoogleSignIn

class ProfileViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var changeAccountTextField: UITextField!
    
    @IBOutlet weak var cancelChangeButton: UIButton!
    @IBOutlet weak var editChangeButton: UIButton!
    @IBOutlet weak var changeAccountNameView: UIView!
    
    @IBOutlet weak var changeAccountPassword: UIView!
    
    @IBOutlet weak var changeAccountPasswordTextField: UITextField!
    
    @IBOutlet weak var changeAccountNewTextField: UITextField!
    
    @IBOutlet weak var cancelChangePasswordButton: UIButton!
    
    @IBOutlet weak var editChangePasswordButton: UIButton!
    
    @IBOutlet weak var changeAccountImage: UIView!
    
    @IBOutlet weak var bottomChangeImageView: NSLayoutConstraint!
    
    @IBOutlet weak var tackPicktureButton: UIButton!
    
    @IBOutlet weak var importGallerryButton: UIButton!
    
    
    var  headerProfileView = HeaderProfileView()
    var sections = ["", "Account", "Uptodo"]
    var imageProfile = [
                                        1: ["user", "key 1", "camera"],
                                        2: ["menu 1", "info-circle", "flash", "like", "logout"]
                            ]
    
    var contenProfile = [
                                        1: ["Change account name", "Change account password", "Change account Image"],
                                        2: ["About US", "FAQ", "Help & Feedback", "Support US", "Log out"]
                            ]
    
    private lazy var imagePicker: ImagePicker = {
           let imagePicker = ImagePicker()
           imagePicker.delegate = self
           return imagePicker
       }()
    
    var viewModle = HomeViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hexString:"FFFFFF", alpha: 0.87) ?? UIColor()]
        title = "Profile"
        
        tableView.register(UINib(nibName: "ProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "ProfileTableViewCell")
        self.navigationController?.isNavigationBarHidden = true
        print(self.tabBarController?.getHeight())
        setupChangeAccountName()
        setupChangeAccountPass()
        setupChangeAccountImage()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapToDismiss(_:)))
               tapGestureRecognizer.delegate = self
               view.addGestureRecognizer(tapGestureRecognizer)
        
        
        if NetworkMonitor.shared.isConnected {
                    ProfileManager.shared.downloadFile { results in
                        switch results {
            
                            case .success(let url):
                                print("URL: \(url)")
            
                            self.headerProfileView.profileImage.kf.setImage(with: URL(string: "\(url)"))
            
                            case .failure(let error):
                                print("Upload error: \(error)")
            
                        }
                    }
            
            headerProfileView.fullNameProfile.text = Auth.auth().currentUser?.displayName ?? ""
        }else{
            
            if let urlString = UserDefaults.standard.string(forKey: "profilePicture") {
                if let url = URL(string: urlString) {
                    // Sử dụng biến url tại đây
                    self.headerProfileView.profileImage.kf.setImage(with: URL(string: "\(url)"))
                } else {
                    print("URL string không hợp lệ")
                }
            } else {
                print("Không tìm thấy URL trong UserDefaults")
            }

            headerProfileView.fullNameProfile.text = UserDefaults.standard.string(forKey: "nameProfile")
            
        }
    }
    func checklogin(){
        if Auth.auth().currentUser != nil {
                print("User logged in")
              } else {
                  print("User")
                  let storyb = storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
                  let navi = UINavigationController(rootViewController:storyb )
                  navi.modalPresentationStyle = .fullScreen
                  present(navi, animated: true)
              }
    }
    
    @objc func tapToDismiss(_ recognizer: UITapGestureRecognizer) {
           let location = recognizer.location(in: view)
           
           // Check if the touch was inside the categoryView
           if   !changeAccountImage.isHidden && !changeAccountImage.frame.contains(location){
               changeAccountImage.isHidden = true
               self.tabBarController?.tabBar.isHidden = false
               return
           }
       }
    
  //   UIGestureRecognizerDelegate method
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: view)
        
        // Check if the touch is within any of the subviews
        if( !changeAccountImage.isHidden && changeAccountImage.frame.contains(location)){
            return false
        }
        
        return !changeAccountImage.isHidden
    }
   
    func setupChangeAccountName(){
        changeAccountNameView.layer.cornerRadius = 4
        changeAccountNameView.layer.masksToBounds = true
        

        changeAccountTextField.layer.borderWidth = 1
        changeAccountTextField.layer.borderColor = UIColor(hexString: "979797")?.cgColor
        changeAccountTextField.layer.cornerRadius = 4
        changeAccountTextField.layer.masksToBounds = true
        
        editChangeButton.layer.cornerRadius = 4
        editChangeButton.layer.masksToBounds = true
        
        cancelChangeButton.addTarget(self, action: #selector(cancelChangeAccountName), for: .touchUpInside)
        editChangeButton.addTarget(self, action: #selector(editChangeAccountName), for: .touchUpInside)
    }
    
    func setupChangeAccountPass(){
        changeAccountPassword.layer.cornerRadius = 4
        changeAccountPassword.layer.masksToBounds = true
        

        changeAccountPasswordTextField.layer.borderWidth = 1
        changeAccountPasswordTextField.layer.borderColor = UIColor(hexString: "979797")?.cgColor
        changeAccountPasswordTextField.layer.cornerRadius = 4
        changeAccountPasswordTextField.layer.masksToBounds = true
        
        changeAccountNewTextField.layer.borderWidth = 1
        changeAccountNewTextField.layer.borderColor = UIColor(hexString: "979797")?.cgColor
        changeAccountNewTextField.layer.cornerRadius = 4
        changeAccountNewTextField.layer.masksToBounds = true
        
        editChangePasswordButton.layer.cornerRadius = 4
        editChangePasswordButton.layer.masksToBounds = true
        
        cancelChangePasswordButton.addTarget(self, action: #selector(cancelChangeAccountName), for: .touchUpInside)
        editChangePasswordButton.addTarget(self, action: #selector(editHandleChangeAccountName), for: .touchUpInside)
    }
    
    func setupChangeAccountImage(){
        tackPicktureButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
        importGallerryButton.addTarget(self, action: #selector(photoButtonTapped), for: .touchUpInside)
    }
    @objc func photoButtonTapped(_ sender: UIButton) {
        imagePicker.photoGalleryAsscessRequest()
        changeAccountImage.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
    }
    @objc func cameraButtonTapped(_ sender: UIButton) {
        imagePicker.cameraAsscessRequest()
        changeAccountImage.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
    }
    @objc func cancelChangeAccountName(){
        changeAccountNameView.isHidden = true
        changeAccountPassword.isHidden = true
       
    }
    @objc func editChangeAccountName(){
        changeAccountNameView.isHidden = true
        changeProfileName()
    }
    
    @objc func editHandleChangeAccountName(){
        
        changeAccountPassword.isHidden = true
        changePassword(oldPassword: changeAccountPasswordTextField.text ?? "", newPassword: changeAccountNewTextField.text ?? "")
    }
}
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0: return 0
        case 1: return 3
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
            cell.profileImage.image = UIImage(named: imageName)
               }
        if (section == sections.count - 1) && (row == 4){
            cell.contentLable.textColor = UIColor(hexString: "FF4949")
            cell.rightImage.isHidden = true
        }
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 1{
            
            if row == 0{
                changeAccountNameView.isHidden = false
            }else if row == 1{
                changeAccountPassword.isHidden = false
               
            }else{
                changeAccountImage.isHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                    self?.tabBarController?.tabBar.isHidden = true
                }
                updateChangeAccountImageConstraint()
            }
        }
        if section == 2{
            
            if row == 4 {
                viewModle.deleteAllData()
                UserDefaults.standard.removeObject(forKey: "profilePicture")
                UserDefaults.standard.removeObject(forKey: "nameProfile")
                
                signout()
                checklogin()
            }
        }
        
    }
    func changePassword(oldPassword: String, newPassword: String) {
        let signInStyle = UserDefaults.standard.string(forKey: "signInStyle")
        
        guard let user = Auth.auth().currentUser, let email = user.email else {
            print("Người dùng không hợp lệ hoặc không có email")
            return
        }
        switch "google"{
        case "email":
           
            // Tạo thông tin xác thực
            let credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword)
            
            // Tái xác thực người dùng
            user.reauthenticate(with: credential) { authResult, error in
                if let error = error {
                    print("Lỗi khi tái xác thực: \(error.localizedDescription)")
                    return
                }
                
                // Cập nhật mật khẩu
                user.updatePassword(to: newPassword) { error in
                    if let error = error {
                        print("Lỗi khi cập nhật mật khẩu: \(error.localizedDescription)")
                        return
                    }
                }
            }
            
        case "google":
            
            let googleUser = GIDSignIn.sharedInstance.currentUser
            guard let idToken = googleUser?.idToken?.tokenString else{
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: (googleUser?.accessToken.tokenString)!)
            user.reauthenticate(with: credential) { (authResult, error) in
                       if let error = error {
                           // Handle re-authentication error
                           print("Re-authentication with Google failed: \(error.localizedDescription)")
                           return
                       }

                       // Re-authenticate the user with their old password
                       let email = user.email ?? ""
                       let passwordCredential = EmailAuthProvider.credential(withEmail: email, password: oldPassword)

                       user.reauthenticate(with: passwordCredential) { (authResult, error) in
                           if let error = error {
                               // Handle re-authentication error
                               print("Re-authentication with old password failed: \(error.localizedDescription)")
                               return
                           }

                           // Update the password to the new password
                           user.updatePassword(to: newPassword) { (error) in
                               if let error = error {
                                   // Handle password update error
                                   print("Password update failed: \(error.localizedDescription)")
                                   return
                               }
                               print("Password updated successfully")
                           }
                       }
                   }
            break
        case "apple":
            
            break
        default:
            break
        }
      
        
     
                
                // Cập nhật mật khẩu mới vào UserDefaults
                UserDefaults.standard.set(newPassword, forKey: "password")
                print("Cập nhật mật khẩu thành công")
            
    }
    
    
    func changeProfileName(){
        let user = Auth.auth().currentUser
        let changeRequest = user?.createProfileChangeRequest()
        changeRequest?.displayName = changeAccountTextField.text ?? ""
        changeRequest?.commitChanges { error in
            if let error = error {
                print("Lỗi khi cập nhật displayName: \(error.localizedDescription)")
            } else {
                print("Cập nhật displayName thành công")
                self.headerProfileView.fullNameProfile.text = self.changeAccountTextField.text ?? ""
                UserDefaults.standard.set(self.changeAccountTextField.text ?? "", forKey: "nameProfile")
            }
        }
    }
    
    
    func signout(){
        do {
            try Auth.auth().signOut()
            
        }catch{
            print("SignOut faild")
        }
    }
        func updateChangeAccountImageConstraint() {
              // Update the constraint
            bottomChangeImageView.constant = -(self.tabBarController?.getHeight() ?? CGFloat())
              
              // Animate the change
              UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                  self.view.layoutIfNeeded()
              }, completion: { _ in
                  print("Animation completed")
              })
        }
    
    
    // Tùy chỉnh tiêu đề cho header của section
      func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
          
          if section == 0 {
              
              return headerProfileView
          }else{
             let  headerView1 = UIView()
              headerView1.backgroundColor = .clear
              
              let label = UILabel()
              label.text = self.sections[section]
              label.textColor = UIColor(hexString: "AFAFAF")
              label.font = UIFont.boldSystemFont(ofSize: 16)
              
              headerView1.addSubview(label)
              
              label.translatesAutoresizingMaskIntoConstraints = false
              NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: headerView1.leadingAnchor, constant: 16),
                label.trailingAnchor.constraint(equalTo: headerView1.trailingAnchor, constant: -16),
                label.topAnchor.constraint(equalTo: headerView1.topAnchor, constant: 8),
                label.bottomAnchor.constraint(equalTo: headerView1.bottomAnchor, constant: -8)
              ])
              return headerView1
          }
          
          return UIView()
      }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
extension ProfileViewController: ImagePickerDelegate {

    func imagePicker(_ imagePicker: ImagePicker, didSelect image: UIImage) {
        // Convert UIImage to Data
        
//        UserDefaults.standard.set(image, forKey: "profilePicture")
         guard let imageData = image.jpegData(compressionQuality: 1.0) else {
             print("Unable to convert UIImage to Data")
             return
         }
        self.headerProfileView.profileImage.image = image
         // Create a temporary file URL to save the image
         let temporaryDirectoryURL = FileManager.default.temporaryDirectory
         let fileName = UUID().uuidString + ".jpg"
         let fileURL = temporaryDirectoryURL.appendingPathComponent(fileName)
         
       
        do {
                // Save the Data to the temporary file URL
                try imageData.write(to: fileURL)
                
                // Upload the file using ProfileManager
                ProfileManager.shared.uploadFile(fileUrl: fileURL) { result in
                    switch result {
                    case .success(let url):
                        print("URL: \(url.absoluteString)")
                        UserDefaults.standard.set(url.absoluteString, forKey: "profilePicture")
                       
                    case .failure(let error):
                        print("Upload error: \(error)")
                    }
                }
            } catch {
                print("Unable to save file: \(error)")
            }
        
        imagePicker.dismiss()
    }

    func cancelButtonDidClick(on imageView: ImagePicker) { imagePicker.dismiss() }
    func imagePicker(_ imagePicker: ImagePicker, grantedAccess: Bool,
                     to sourceType: UIImagePickerController.SourceType) {
        guard grantedAccess else { return }
        imagePicker.present(parent: self, sourceType: sourceType)
    }
}

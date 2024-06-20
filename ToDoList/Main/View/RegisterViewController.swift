//
//  RegisterViewController.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 07/06/2024.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextFiedl: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    //@IBOutlet weak var googleLoginButton: UIButton!
    //@IBOutlet weak var appleLoginButton: UIButton!
    @IBOutlet weak var backLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSetupView()
  
    }
    @objc func registerHandle(){
        print("registerHandle")
        guard let email = usernameTextField.text, let password = passwordTextFiedl.text, let confirmPassword = confirmPasswordTextField.text else{
            return
        }
        if email.isEmpty {
            print("Fill email in textField")
            return
        }
        if password.isEmpty && confirmPassword.isEmpty && password.count >= 6 {
            print("Fill password or confirmPassword more than 6 character in textField")
            return
        }
        
        if password != confirmPassword{
            print("Password and confirmPassword no match")
            return
        }
        if isValidEmail(email) == false{
            print("Email invalid")
            return
        }
        UserDefaults.standard.set(email, forKey: "email")
        UserDefaults.standard.set(password, forKey: "password")
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            guard let user = authResult?.user, error == nil else {
                       if let error = error {
                           print("Lỗi khi tạo người dùng: \(error.localizedDescription)")
                       }
                       return
                   }
            UserDefaults.standard.setValue("email", forKey: "signInStyle")
            
//                   let changeRequest = user.createProfileChangeRequest()
//                   changeRequest.displayName = email
//                   changeRequest.commitChanges { error in
//                       if let error = error {
//                           print("Lỗi khi cập nhật displayName: \(error.localizedDescription)")
//                       } else {
//                           print("Cập nhật displayName thành công")
//                       }
//                   }
            self.navigationController?.dismiss(animated: true)
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    @objc func googleHandle(){
        print("googleHandle")
    }
    @objc func appleHandle(){
        print("appleHandle")
    }
    @objc func backToLogin(){
        navigationController?.popViewController(animated: true)
    }
    @objc func viewdidEdit(){
        view.endEditing(true)
    }
    func configureSetupView(){
        registerButton.layer.cornerRadius = 4
        registerButton.layer.masksToBounds = true
        usernameTextField.keyboardAppearance = .dark
        passwordTextFiedl.keyboardAppearance = .dark
        confirmPasswordTextField.keyboardAppearance = .dark
//        googleLoginButton.layer.cornerRadius = 4
//        googleLoginButton.layer.masksToBounds = true
//        googleLoginButton.layer.borderWidth = 1
//        googleLoginButton.layer.borderColor = UIColor(hexString: "8875FF")?.cgColor
        
//        appleLoginButton.layer.cornerRadius = 4
//        appleLoginButton.layer.masksToBounds = true
//        appleLoginButton.layer.borderWidth = 1
//        appleLoginButton.layer.borderColor = UIColor(hexString: "8875FF")?.cgColor
        
        
        
        //back
        let backButton = UIBarButtonItem(image: UIImage(named: "Frame 185"), style: .plain, target: self, action: #selector(backToLogin))
              navigationItem.leftBarButtonItem = backButton
        navigationController?.navigationBar.tintColor = .white
        
        
        let placeholderText1 = "Enter your email"
               let attributes: [NSAttributedString.Key: Any] = [
                   .foregroundColor: UIColor.lightGray, // Placeholder text color
                   .font: UIFont.italicSystemFont(ofSize: 16) // Placeholder font
               ]
               usernameTextField.attributedPlaceholder = NSAttributedString(string: placeholderText1, attributes: attributes)
               
        
        let placeholderText2 = "........"
               
               passwordTextFiedl.attributedPlaceholder = NSAttributedString(string: placeholderText2, attributes: attributes)
               confirmPasswordTextField.attributedPlaceholder = NSAttributedString(string: placeholderText2, attributes: attributes)
           
       
    
        //handle
        backLoginButton.addTarget(self, action: #selector(backToLogin), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerHandle), for: .touchUpInside)
    //    googleLoginButton.addTarget(self, action: #selector(googleHandle), for: .touchUpInside)
       // appleLoginButton.addTarget(self, action: #selector(appleHandle), for: .touchUpInside)
    }
   
}

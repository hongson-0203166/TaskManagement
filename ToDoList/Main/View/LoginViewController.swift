//
//  LoginViewController.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 07/06/2024.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
class LoginViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var appleLoginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar
        let appearance = UINavigationBarAppearance()
                appearance.configureWithTransparentBackground() // Makes the background transparent
                appearance.backgroundColor = .clear // Ensures the background color is clear
                appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // Title color

                // Apply the appearance to the navigation bar
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        configureSetupView()
       // usernameTextField.becomeFirstResponder()
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewdidEdit)))
    }
    @objc func viewdidEdit(){
        contentView.endEditing(true)
    }
    func configureSetupView(){
        loginButton.layer.cornerRadius = 4
        loginButton.layer.masksToBounds = true
        
        googleLoginButton.layer.cornerRadius = 4
        googleLoginButton.layer.masksToBounds = true
        googleLoginButton.layer.borderWidth = 1
        googleLoginButton.layer.borderColor = UIColor(hexString: "8875FF")?.cgColor
        
        appleLoginButton.layer.cornerRadius = 4
        appleLoginButton.layer.masksToBounds = true
        appleLoginButton.layer.borderWidth = 1
        appleLoginButton.layer.borderColor = UIColor(hexString: "8875FF")?.cgColor
        
        let placeholderText1 = "Enter your email"
               let attributes: [NSAttributedString.Key: Any] = [
                   .foregroundColor: UIColor.lightGray, // Placeholder text color
                   .font: UIFont.italicSystemFont(ofSize: 16) // Placeholder font
               ]
               usernameTextField.attributedPlaceholder = NSAttributedString(string: placeholderText1, attributes: attributes)
        let placeholderText = "........"
        passwordTextField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        
        //backLoginButton.addTarget(self, action: #selector(backToLogin), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(registerHandle), for: .touchUpInside)
        googleLoginButton.addTarget(self, action: #selector(googleHandle), for: .touchUpInside)
        appleLoginButton.addTarget(self, action: #selector(appleHandle), for: .touchUpInside)
    }
    @objc func googleHandle(){
        print("googleHandle")
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                return
            }
            
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                return
              }
            let email = user.profile?.email
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                             accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { result, error in
                guard error == nil, result != nil else {
                    return
                }
               
                UserDefaults.standard.set( result?.user.email, forKey: "email")
                //UserDefaults.standard.set(result?.user.pass, forKey: "password")

                self.navigationController?.dismiss(animated: true)
              // At this point, our user is signed in
            }
        }
    }
    @objc func appleHandle(){
        print("appleHandle")
    }
    @objc func registerHandle(){
        
        guard let email = usernameTextField.text, let password = passwordTextField.text else{
            return
        }
        if email.isEmpty {
            print("Fill email in textField")
            return
        }
        if password.isEmpty  || password.count < 6 {
            print("Fill password more than 6 character in textField")
            return
        }
        
        func isValidEmail(_ email: String) -> Bool {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailPred.evaluate(with: email)
        }
        
        if isValidEmail(email) == false{
            print("Email invalid")
            return
        }
        
        UserDefaults.standard.set(email, forKey: "email")
        UserDefaults.standard.set(password, forKey: "password")
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
            guard authResult != nil, error == nil else{
                print("\(error)")
                self?.showAlertError(message: "Login faild. Please relogin")
                return
            }
            strongSelf.navigationController?.dismiss(animated: true)
        }
   
    }
    func showAlertError( message: String){
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(action)
        present(alert, animated: true)
    }
}

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
import AuthenticationServices
import CryptoKit
class LoginViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var appleLoginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var loginProviderStackView: UIStackView!
    var currentNonce: String?
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
        
 //       setupProviderLoginView()

    }
   

    // Function to generate a random nonce
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }
    /// - Tag: add_appleid_button
//    func setupProviderLoginView() {
//        let authorizationButton = ASAuthorizationAppleIDButton()
//        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
//        self.loginProviderStackView.addArrangedSubview(authorizationButton)
//    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      //  performExistingAccountSetupFlows()
    }
    func performExistingAccountSetupFlows() {
        // Prepare requests for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]
        
        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    // - Tag: perform_appleid_request
    /// - Tag: perform_appleid_request
    @objc
    func handleAuthorizationAppleIDButtonPress() {
        let nonce = randomNonceString()
           currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    // SHA256 hash function
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
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
        usernameTextField.keyboardAppearance = .dark
        passwordTextField.keyboardAppearance = .dark
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
        
        appleLoginButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
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
                UserDefaults.standard.setValue("google", forKey: "signInStyle")
                //UserDefaults.standard.set( result?.user.email, forKey: "email")
                //UserDefaults.standard.set(result?.user.pass, forKey: "password")

                self.navigationController?.dismiss(animated: true)
              // At this point, our user is signed in
            }
        }
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
        
//        UserDefaults.standard.set(email, forKey: "email")
//        UserDefaults.standard.set(password, forKey: "password")
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
            guard authResult != nil, error == nil else{
                print("\(error)")
                self?.showAlertError(message: "Login faild. Please relogin")
                return
            }
            UserDefaults.standard.setValue("email", forKey: "signInStyle")
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
extension LoginViewController: ASAuthorizationControllerDelegate {
    /// - Tag: did_complete_authorization
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            guard let nonce = currentNonce else {
                        fatalError("Invalid state: A login callback was received, but no login request was sent.")
                    }
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            print(email)
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                           print("Unable to fetch identity token")
                           return
                       }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                        print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                        return
                    }
            UserDefaults.standard.setValue(idTokenString, forKey: "idToken")
            UserDefaults.standard.setValue(nonce, forKey: "rawNonce")
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    // Handle error
                    print("Error authenticating with Firebase: \(error.localizedDescription)")
                    return
                }
                
                // User is signed in to Firebase with Apple.
                if let user = authResult?.user {
                    print("Successfully signed in with Apple ID: \(user.uid)")
//                    user.profile?.email
                    UserDefaults.standard.setValue("apple", forKey: "signInStyle")
//                    UserDefaults.standard.set(appleIDCredential.email, forKey: "email")
//                    // Store the `userIdentifier` in the keychain.
//                    let email = UserDefaults.standard.string(forKey: "email")
//                    print(email)
                    
                    self.saveUserInKeychain(userIdentifier)
                    self.navigationController?.dismiss(animated: true)
                    
                }
            }
  
        case let passwordCredential as ASPasswordCredential:
        
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
       
        default:
            break
        }
    }
    
    private func saveUserInKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: "com.bhsoft.TaskManagement", account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            print("Unable to save userIdentifier to keychain.")
        }
    }

    /// - Tag: did_complete_error
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}




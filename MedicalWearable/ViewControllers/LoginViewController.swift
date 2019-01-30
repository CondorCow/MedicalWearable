//
//  LoginViewController.swift
//  MedicalWearable
//
//  Created by Danny Janssen on 24/01/2019.
//  Copyright © 2019 DannyJanssen. All rights reserved.
//

import UIKit
import Alamofire
import SnapKit
import LocalAuthentication

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    let interactor = AuthInteractor()
    let utils = ViewControllerUtils()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setConstraints()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        passwordTextField.delegate = self
        
        //TODO: Remove
        emailTextField.text = "danny.janssen@indicia.nl"
        passwordTextField.text = "password"
        
//        touchIdAction()
    }
    
    func setConstraints() {
        emailTextField.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().inset(50)
        }
        
        passwordTextField.snp.makeConstraints{ make in
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.leading.equalTo(emailTextField)
            make.trailing.equalTo(emailTextField)
        }
    }
    
//    func touchIdAction() {
//
//        print("hello there!.. You have clicked the touch ID")
//
//        let myContext = LAContext()
//        let myLocalizedReasonString = "\"\(emailTextField.text!)\""
//
//        var authError: NSError?
//        if #available(iOS 8.0, macOS 10.12.1, *) {
//            if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
//                myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString) { success, evaluateError in
//
//                    DispatchQueue.main.async {
//                        if success {
//                            print("User authenticated successfully")
//                            self.performSegue(withIdentifier: "goToMain", sender: self)
//                        } else {
//                            print("User did not authenticate successfully")
//                        }
//                    }
//                }
//            } else {
//                print("Could not evaluate policy.")
//            }
//        } else {
//            print("This feature is not supported.")
//        }
//
//    }

    
    @IBAction func loginButtonPressed(_ sender: Any) {
        utils.showActivityIndicator(uiView: view)
        interactor.login(emailTextField.text!, passwordTextField.text!) { (success, title, message) in
            if success {
                self.performSegue(withIdentifier: "goToMain", sender: self)
            } else {
                var alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                var action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                })
                alert.addAction(action)
                self.present(alert, animated: true)
            }
            self.utils.hideActivityIndicator(uiView: self.view)
        }
    }
    
    @IBAction func unwindToLoginViewController(segue: UIStoryboardSegue){}
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        loginButton.sendActions(for: .touchUpInside)
        return true
    }
    
    @objc func dismissKeyboard(){
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
}

//
//  PincodeViewController.swift
//  MedicalWearable
//
//  Created by Danny Janssen on 15/02/2019.
//  Copyright © 2019 DannyJanssen. All rights reserved.
//

import UIKit

class PincodeViewController: UIViewController {
    
    var newPincode: Bool = false

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pincodeTextField: UITextField!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    
    let interactor = AuthInteractor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newPincode = !Variables.isPincodeSet()
        print("newPincode", newPincode)
        
        setUpView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func setUpView() {
        // TITLE
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(150)
        }
        
        titleLabel.text = newPincode ? "Kies een pincode" : "Voer uw pincode in"
        titleLabel.font = titleLabel.font.withSize(24)
        
        informationLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(100)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
        }
        
        informationLabel.numberOfLines = 0
        informationLabel.text = newPincode ?
            "Gebruik uw pincode wanneer u terug in de app komt na het sluiten van de app. Deze pincode is 24 uur geldig." :
            ""
        informationLabel.textColor = UIColor.flatGray()
        informationLabel.font = informationLabel.font.withSize(18)
        informationLabel.textAlignment = .center
        
        // PINCODE
        pincodeTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().inset(50)
        }
        
        pincodeTextField.keyboardType = .decimalPad
        
        // ERRORS
        errorLabel.snp.makeConstraints{ make in
            make.bottom.equalTo(pincodeTextField.snp.top)
            make.leading.equalTo(pincodeTextField.snp.leading)
        }
        
        errorLabel.textColor = .red
        errorLabel.text = "errors"
        errorLabel.isHidden = true
        
        // BUTTON
        continueButton.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.top.equalTo(pincodeTextField.snp.bottom).offset(50)
        }
        
        continueButton.setTitle("Verder", for: .normal)
    }

    @IBAction func setPincodeButtonPressed(_ sender: Any) {
        guard let text = pincodeTextField.text else {
            return
        }
        
        if text.count > 5 {
            errorLabel.text = "Maximaal 5 cijfers toegestaan"
            errorLabel.isHidden = false
        } else {
            if newPincode {
                interactor.setPincode(pin: pincodeTextField.text!) { success in
                    if success {
                        self.performSegue(withIdentifier: "goToMain", sender: self)
                    }
                }
            } else {
                interactor.checkPincode(pin: pincodeTextField.text!) { success in
                    if success {
                        self.performSegue(withIdentifier: "goToMain", sender: self)
                    } else {
                        errorLabel.text = "Onjuiste pincode ingevoerd"
                        errorLabel.isHidden = false
                    }
                }
            }
        }
    }
    
    func toN() {
        
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        pincodeTextField.resignFirstResponder()
    }
}

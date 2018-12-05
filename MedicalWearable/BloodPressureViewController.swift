//
//  BloodPressureViewController.swift
//  MedicalWearable
//
//  Created by Danny Janssen on 27/11/2018.
//  Copyright © 2018 DannyJanssen. All rights reserved.
//

import UIKit
import SnapKit

class BloodPressureViewController: UIViewController {
    @IBOutlet weak var emptyScreenLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addConstraints()
        
        emptyScreenLabel.lineBreakMode = .byWordWrapping
        emptyScreenLabel.numberOfLines = 0
        emptyScreenLabel.text = "Blood pressure calculations are not yet available at this moment"
        emptyScreenLabel.textColor = UIColor.flatGray()
        emptyScreenLabel.textAlignment = .center
        emptyScreenLabel.sizeToFit()
    }
    
    func addConstraints(){
        emptyScreenLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
        }
    }
}

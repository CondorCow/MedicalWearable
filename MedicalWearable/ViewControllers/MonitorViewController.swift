//
//  BloodPressureViewController.swift
//  MedicalWearable
//
//  Created by Danny Janssen on 27/11/2018.
//  Copyright © 2018 DannyJanssen. All rights reserved.
//q

import UIKit
import SnapKit
import ABGaugeViewKit

class MonitorViewController: UIViewController {
    @IBOutlet weak var systolicGaugeView: ABGaugeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSettings()
        addConstraints()
        test()
    }
    
    func addSettings(){
        systolicGaugeView.colorCodes = "FFFACD,ADFF2F,"
    }
    
    func addConstraints(){
        systolicGaugeView.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(240)
            make.width.equalTo(240)
        }
    }
    
    func test(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.systolicGaugeView.needleValue = 40
        }
    }
}

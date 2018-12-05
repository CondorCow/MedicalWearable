//
//  MenuViewController.swift
//  MedicalWearable
//
//  Created by Danny Janssen on 23/11/2018.
//  Copyright © 2018 DannyJanssen. All rights reserved.
//

import UIKit
import SnapKit
import ViewAnimator
import Floaty

class MenuViewController: UIViewController {
    
    let floaty = Floaty()

    @IBOutlet weak var heartRateButton: UIButton!
    @IBOutlet weak var bloodPressureButton: UIButton!
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var bloodPressureLabel: UILabel!
    var buttonsContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor.flatMint()
        
        addContainer()
        setupConstraints()
        animateViews(withDelay: 0.3, withDuration: 0.3)
        addFloaty()
    }

    private func addContainer(){
        buttonsContainer = UIView(frame: CGRect(x: 250, y: 100, width: 100, height: 250))
        view.addSubview(buttonsContainer)
        
        //Heart Rate Button
        heartRateButton.layer.cornerRadius = 50
        heartRateButton.backgroundColor = UIColor.flatRed()
        buttonsContainer.addSubview(heartRateButton)
        
        //Blood Pressure Button
        bloodPressureButton.layer.cornerRadius = 50
        bloodPressureButton.backgroundColor = UIColor.flatMint()
        buttonsContainer.addSubview(bloodPressureButton)
        
        //Labels below buttons
        heartRateLabel.text = "Heart Rate Monitor"
//        bloodPressureLabel.text = "Blood Pressure Monitor"
        
        //TODO: Strikethrough label because Blood Pressure is not yet implemented
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "Blood Pressure Monitor")
        attributeString.addAttribute(.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        bloodPressureLabel.attributedText = attributeString

        buttonsContainer.addSubview(heartRateLabel)
        buttonsContainer.addSubview(bloodPressureLabel)
    }
    
    private func setupConstraints(){
        buttonsContainer.snp.makeConstraints { (make) in
            let safeArea = view.safeAreaLayoutGuide.layoutFrame
            if let navigationBar = navigationController?.navigationBar {
                make.width.equalTo(100)
                make.height.equalTo(300)
                print(safeArea.size.height)
                print(navigationBar.frame.size.height)
                print(buttonsContainer.frame.size.height / 2)
                make.centerY.equalToSuperview().offset(navigationBar.frame.size.height / 2)
                make.leading.equalTo((self.view.frame.size.width / 2) - (buttonsContainer.frame.size.width / 2))
            }
        }
        heartRateButton.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(100)
            make.top.equalTo(buttonsContainer.snp.top)
            make.leading.equalTo(buttonsContainer.snp.leading)
        }
        heartRateLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(heartRateButton.snp.bottom).offset(10)
        }
        bloodPressureButton.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(100)
            make.bottom.equalTo(buttonsContainer.snp.bottom).inset(30)
            make.leading.equalTo(buttonsContainer.snp.leading)
        }
        bloodPressureLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(bloodPressureButton.snp.bottom).offset(10)
        }
    }
    
    func animateViews(withDelay delay: Double, withDuration duration: Double){
        let animation = AnimationType.zoom(scale: 0.5)
        heartRateButton.animate(animations: [animation],
                                 reversed: false,
                                 initialAlpha: 0,
                                 finalAlpha: 1,
                                 delay: delay,
                                 duration: duration,
                                 completion: nil)
        heartRateLabel.animate(animations: [animation],
                                reversed: false,
                                initialAlpha: 0,
                                finalAlpha: 1,
                                delay: delay,
                                duration: duration,
                                completion: nil)
        bloodPressureButton.animate(animations: [animation],
                                reversed: false,
                                initialAlpha: 0,
                                finalAlpha: 1,
                                delay: delay + 0.2,
                                duration: duration,
                                completion: nil)
        bloodPressureLabel.animate(animations: [animation],
                                reversed: false,
                                initialAlpha: 0,
                                finalAlpha: 1,
                                delay: delay + 0.2,
                                duration: duration,
                                completion: nil)
    }
    
    func addFloaty(){
        //Floating action button itself
        floaty.buttonColor = UIColor.flatRed()
        floaty.plusColor = UIColor.white
        
        //Information button
        let informationItem = FloatyItem()
        informationItem.icon = UIImage(named: "info-icon.png")
        informationItem.handler = {(item) in
            self.performSegue(withIdentifier: "goToInformation", sender: self)
        }
        floaty.addItem(item: informationItem)
        
        //Help button
        let helpItem = FloatyItem()
        helpItem.icon = UIImage(named: "questionmark-icon.png")
        helpItem.handler = {(item) in
            
        }
        floaty.addItem(item: helpItem)
        
        self.view.addSubview(floaty)
    }
    
    @IBAction func heartRateButtonPressed(_ sender: UIButton) {
        print("goToHeartRateMonitor")
        performSegue(withIdentifier: "goToHeartRateMonitor", sender: self)
    }
    @IBAction func bloodPressureButtonPressed(_ sender: UIButton) {
        print("goToHeartRateMonitor")
        performSegue(withIdentifier: "goToBloodPressureMonitor", sender: self)
    }
}

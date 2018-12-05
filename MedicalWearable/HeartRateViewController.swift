//
//  ViewController.swift
//  MedicalWearable
//
//  Created by Danny Janssen on 22/11/2018.
//  Copyright © 2018 DannyJanssen. All rights reserved.
//

import UIKit
import CoreBluetooth
import M13ProgressSuite
import ChameleonFramework

class HeartRateViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var manager: CBCentralManager!
    var mioLink: CBPeripheral!
    @IBOutlet weak var bodyLocationLabel: UITextView!
    @IBOutlet weak var heartRateLabel: UITextView!
    
    var finishedSearch: Bool = false
    var timeOutRunning: Bool = false
    
    var progressHUD: M13ProgressHUD!

    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CBCentralManager(delegate: self, queue: nil)
        progressHUD = M13ProgressHUD(progressView: M13ProgressViewPie())
        addProgressHUD()
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Name: \(peripheral.name)")
        if progressHUD.progress != 0.15 {
            changeProgressHudStatus(progressValue: 0.15, withStatus: "Searching for MioLink")
        }
        if !timeOutRunning {
            timeOutRunning = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                print("Timeout reached")
                if !self.finishedSearch {
                    self.progressHUD.hide(true)
                    let alert = UIAlertController(title: "Error", message: "No MioLink found", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    })

                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        if peripheral.name?.contains("MIO") == true{
            finishedSearch = true
            print("Mio found")
            changeProgressHudStatus(progressValue: 0.55, withStatus: "Connecting to MioLink")
            self.mioLink = peripheral
            self.mioLink.delegate = self
            
            manager.stopScan()
            manager.connect(self.mioLink, options: nil)
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let servicePeripherals = peripheral.services as [CBService]!
        {
            for service in servicePeripherals{
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    private func bodyLocation(from characteristic: CBCharacteristic) -> String{
        guard let characteristicData = characteristic.value,
            let byte = characteristicData.first else { return "Error" }
        
        switch byte {
        case 0: return "Other"
        case 1: return "Chest"
        case 2: return "Wrist"
        case 3: return "Finger"
        case 4: return "Hand"
        case 5: return "Ear Lobe"
        case 6: return "Foot"
        default:
            return "Reserved for future use"
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristicArray = service.characteristics as [CBCharacteristic]!
        {
            for cc in characteristicArray{
//                print(cc.uuid.uuidString)
                if(cc.uuid.uuidString == "2A38"){
                    print("Body location found")
                    peripheral.readValue(for: cc)
                }
                if(cc.uuid.uuidString == "2A37"){
                    print("Heart rate found")
                    peripheral.setNotifyValue(true, for: cc)
                }
            }
            if progressHUD.progress != 0.95 {
                print("Setting up")
                changeProgressHudStatus(progressValue: 0.95, withStatus: "Setting up")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if progressHUD.isVisible() {
            progressHUD.hide(true)
            print("Done")
        }
        switch characteristic.uuid {
        case CBUUID(string: "2A38"):
            let bodySensorLocation = bodyLocation(from: characteristic)
            bodyLocationLabel.text = bodySensorLocation
        //            print(characteristic.value ?? "no value")
        case CBUUID(string: "2A37"):
            let bpm = heartRate(from: characteristic)
            onHeartRateReceived(bpm: bpm)
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
    private func onHeartRateReceived(bpm: Int){
        heartRateLabel.text = String(bpm)
    }
    
    private func heartRate(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        
        let firstBitValue = byteArray[0] & 0x01
        if firstBitValue == 0 {
            // Heart Rate Value Format is in the 2nd byte
            return Int(byteArray[1])
        } else {
            // Heart Rate Value Format is in the 2nd and 3rd bytes
            return (Int(byteArray[1]) << 8) + Int(byteArray[2])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected")
        let alert = UIAlertController(title: "Connection error", message: "MioLink got disconnected. Please reconnect the MioLink.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        })
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var msg = ""
        switch central.state {
        case .unknown:
            print("Bluetooth status is UNKNOWN")
        case .resetting:
            print("Bluetooth status is RESETTING")
        case .unsupported:
            print("Bluetooth status is UNSUPPORTED")
        case .unauthorized:
            print("Bluetooth status is UNAUTHORIZED")
        case .poweredOff:
            print("Bluetooth status is POWERED OFF")
        case .poweredOn:
            print("Bluetooth status is POWERED ON")
            manager.scanForPeripherals(withServices: nil, options: nil)
        default: break
        }
    }
    
    func addProgressHUD(){
        //ProgressHUD
        progressHUD.progressViewSize = CGSize(width: 60.0, height: 60.0)
        progressHUD.animationPoint = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        progressHUD.primaryColor = UIColor.flatMint()
        progressHUD.secondaryColor = UIColor.flatMint()
//        let window: UIWindow = UIApplication.shared.keyWindow!
//        window.addSubview(progressHUD)
        view.addSubview(progressHUD)
        
        //ProgressView
        
        
        //Show Progress
        progressHUD.show(true)
    }
    
    func changeProgressHudStatus(progressValue: Double, withStatus status: String){
        if progressHUD.isVisible() {
            print("Progress: ", progressHUD.progress)
            progressHUD.setProgress(CGFloat(progressValue), animated: true)
            progressHUD.status = status
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        manager?.stopScan()
    }
}

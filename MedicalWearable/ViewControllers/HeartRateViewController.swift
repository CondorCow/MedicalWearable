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
    let wearableName = "Medical Wearable"
    
    var manager: CBCentralManager!
    var mioLink: CBPeripheral!
    @IBOutlet weak var bodyLocationLabel: UITextView!
    @IBOutlet weak var heartRateLabel: UITextView!
    
    var finishedSearch: Bool = false
    var timeOutRunning: Bool = false
    let heartRateBytes: [UInt8] = [0x69, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,0x00,0x00,0x00,0x00, 0x6A]
    let bloodPressureBytes: [UInt8] = [0x69, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,0x00,0x00,0x00,0x00, 0x6B]
    let showResultBytes: [UInt8] = [0x6A, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,0x00,0x00,0x00,0x00, 0x6B]
    
    var progressHUD: M13ProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CBCentralManager(delegate: self, queue: nil)
        
        progressHUD = M13ProgressHUD(progressView: M13ProgressViewPie())
        addProgressHUD()
        bodyLocationLabel.textColor = UIColor.flatGray()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Name: \(peripheral.name)")
        print("Identifier: \(peripheral.identifier)")
        if progressHUD.progress != 0.15 {
            changeProgressHudStatus(progressValue: 0.15, withStatus: "Searching for \(wearableName)")
        }
        
        if !timeOutRunning {
            timeOutRunning = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                print("Timeout reached")
                if !self.finishedSearch {
                    self.progressHUD.hide(true)
                    let alert = UIAlertController(title: "Error", message: "No \(self.wearableName) found", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    })
                    
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        if(peripheral.identifier.uuidString.contains("14140") || peripheral.name?.contains("C80_80") == true) {
            finishedSearch = true
            print("Q8 found")
            changeProgressHudStatus(progressValue: 0.55, withStatus: "Connecting to \(wearableName)")
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
                print("Service uuid: \(service.uuid)")
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
                print("UUID ", cc.uuid.uuidString)
                
                // 00003: TX for reading values, 00002: RX for writing values
                if cc.uuid.uuidString == "6E400003-B5A3-F393-E0A9-E50E24DCCA9E" {
                    peripheral.setNotifyValue(true, for: cc)
                }
                if cc.uuid.uuidString == "6E400002-B5A3-F393-E0A9-E50E24DCCA9E" {
                    peripheral.writeValue(Data(bytes: heartRateBytes), for: cc, type: .withResponse)
                }
            }
            if progressHUD.progress != 0.95 {
                print("Setting up")
                changeProgressHudStatus(progressValue: 0.95, withStatus: "Setting up")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        print("Value written")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if progressHUD.isVisible() {
            progressHUD.hide(true)
            print("Done")
        }
        print("Characteristic UUID: ", characteristic.uuid)
        //        print([UInt8](characteristic.value!))
        
        switch characteristic.uuid {
        case CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"):
            let bpm = heartRate(from: characteristic)
            onHeartRateReceived(bpm: bpm, peripheral, characteristic)
            print(bpm)
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
    private func onHeartRateReceived(bpm: Int, _ peripheral: CBPeripheral, _ cc: CBCharacteristic) {
        if bpm != 0 {
            heartRateLabel.layer.removeAllAnimations()
            heartRateLabel.alpha = 1.0
            heartRateLabel.text = String(bpm)
            
            //Send to show heartrate on screen
//            peripheral.writeValue(Data(bytes: showResultBytes), for: cc, type: .withResponse)
        } else {
            heartRateLabel.text = "- -"
            UIView.animate(withDuration: 0.5, delay: 0.5, options: [.curveEaseOut, .repeat, .autoreverse], animations: {
                self.heartRateLabel.alpha = 0.0
            }, completion: nil)
        }
    }
    
    private func heartRate(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        
        if byteArray.count == 16 {
            //Heart rate is always in 4th byte
            return Int(byteArray[3])
        } else {
            return 0
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected")
        let alert = UIAlertController(title: "Connection error", message: "\(wearableName) got disconnected. Please reconnect the \(wearableName).", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        })
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
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
            showBluetoothOffError()
        case .poweredOn:
            print("Bluetooth status is POWERED ON")
            manager.scanForPeripherals(withServices: nil, options: nil)
        default: break
        }
    }
    
    func showBluetoothOffError() {
        let alert = UIAlertController(title: "Schakel Bluetooth in om '\(wearableName)' verbinding te laten maken met accessoires", message: "", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Instellingen", style: .cancel, handler: { (action) in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        })
        
        alert.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
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
        finishedSearch = false
    }
    
    @objc func willEnterForeground(_ notification: NSNotification!) {
        timeOutRunning = false
        manager?.scanForPeripherals(withServices: nil, options: nil)
    }
}

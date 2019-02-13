//
//  BloodPressureViewController.swift
//  MedicalWearable
//
//  Created by Danny Janssen on 27/11/2018.
//  Copyright © 2018 DannyJanssen. All rights reserved.
//q

import UIKit
import SnapKit
import CoreBluetooth
import M13ProgressSuite
import M13Checkbox

class MonitorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ClientSelectionDelegate, VitalSelectionDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startMeasurementButton: UIButton!
    
    private let interactor = MeasurementInteractor()
    private var selectedClient: Client?
    private let wearableName = "Medical Wearable"
    
    //Get measurementTypes from api
    private var measurementTypes: [MeasurementType] = []
    private var measurements: [Measurement] = []
    
    private var selectedVitals: [Int] = []
    private var currentIndex: Int = 0
    
    // Bluetooth
    var manager: CBCentralManager!
    var newWear: CBPeripheral!
    var bluetoothState: CBManagerState!
    var service: CBService?
    var read: CBCharacteristic?
    var write: CBCharacteristic?
    
    var finishedSearch: Bool = false
    var timeOutRunning: Bool = false
    var setup: Int = 0
    
    let heartRateBytes: [UInt8] = [0x69, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,0x00,0x00,0x00,0x00, 0x6A]
    let bloodPressureBytes: [UInt8] = [0x69, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,0x00,0x00,0x00,0x00, 0x6B]
    let showResultBytes: [UInt8] = [0x6A, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,0x00,0x00,0x00,0x00, 0x6B]
    
    // Checkboxes
    private var checkboxContainer: UIView!
    private var heartCheckbox: M13Checkbox!
    private var bloodPressureCheckbox: M13Checkbox!
    private var heartRateLabel: UILabel!
    private var bloodPressureLabel: UILabel!
    private var containerTitle: UILabel!
    
    var progressHUD: M13ProgressHUD!
    
    // END Bluetooth
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        startMeasurementButton.setTitle("Start meting", for: .normal)
        startMeasurementButton.setTitleColor(.white, for: .normal)
        startMeasurementButton.backgroundColor = UIColor(hexString: "4E749B")?.withAlphaComponent(0.9)
        startMeasurementButton.layer.cornerRadius = 10
        startMeasurementButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        setTableView()
//        setCheckboxes()
        setConstraints()
        retrieveMeasurementTypesAndSections()
        addProgressHUD()
        
        manager = CBCentralManager(delegate: self, queue: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setCheckboxes() {
        checkboxContainer = UIView()
        view.addSubview(checkboxContainer)
        
        heartCheckbox = M13Checkbox()
        heartCheckbox.boxType = .circle
        heartCheckbox.markType = .checkmark
        heartCheckbox.stateChangeAnimation = .expand(.fill)
        heartCheckbox.tintColor = UIColor(hexString: "4E749B")
        checkboxContainer.addSubview(heartCheckbox)
        
        bloodPressureCheckbox = M13Checkbox()
        bloodPressureCheckbox.boxType = .circle
        bloodPressureCheckbox.markType = .checkmark
        bloodPressureCheckbox.stateChangeAnimation = .expand(.fill)
        bloodPressureCheckbox.tintColor = UIColor(hexString: "4E749B")
        checkboxContainer.addSubview(bloodPressureCheckbox)
        
        containerTitle = UILabel()
        containerTitle.text = "Selecteer de type metingen die u wilt uitvoeren:"
        containerTitle.font = containerTitle.font.withSize(13)
        containerTitle.textColor = UIColor.darkGray
        checkboxContainer.addSubview(containerTitle)
        
        heartRateLabel = UILabel()
        heartRateLabel.text = "Hartslag"
        heartRateLabel.font = heartRateLabel.font.withSize(13)
        heartRateLabel.textColor = UIColor.darkGray
        checkboxContainer.addSubview(heartRateLabel)
        
        bloodPressureLabel = UILabel()
        bloodPressureLabel.text = "Bloeddruk"
        bloodPressureLabel.font = bloodPressureLabel.font.withSize(13)
        bloodPressureLabel.textColor = UIColor.darkGray
        checkboxContainer.addSubview(bloodPressureLabel)
    }
    
    func setTableView(){
        tableView.rowHeight = 60
    }
    
    func setConstraints() {
        startMeasurementButton.snp.makeConstraints{make in
            make.bottom.equalToSuperview().inset(30)
            make.centerX.equalToSuperview()
        }
    }
    
    func addProgressHUD(){
        //ProgressHUD
        progressHUD = M13ProgressHUD(progressView: M13ProgressViewPie())
        progressHUD.progressViewSize = CGSize(width: 60.0, height: 60.0)
        progressHUD.animationPoint = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        progressHUD.primaryColor = UIColor.flatMint()
        progressHUD.secondaryColor = UIColor.flatMint()
        view.addSubview(progressHUD)
        
        //Show Progress
//        progressHUD.show(true)
    }
    
    // MARK: TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section){
        case 0:
            return "Cliënt"
        case 1:
            return "Type meting"
        default:
            return ""
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch(indexPath.section) {
        case 0:
            performSegue(withIdentifier: "goToClientSelection", sender: self)
        case 1:
            performSegue(withIdentifier: "goToVitalSelection", sender: self)
        default:
            return 
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClientCell", for: indexPath)
        cell.textLabel!.textColor = UIColor.flatGrayColorDark()
        
        switch(indexPath.section){
        case 0:
            let selected = selectedClient != nil
                ? "\(selectedClient!.lastName), \(selectedClient!.name)"
                : "Geen cliënt geselecteerd"
            cell.textLabel!.text = selected
        case 1:
            let vitals = selectedVitals.isEmpty
                ? "Geen meting types geselecteerd"
                : "\(measurementTypes[selectedVitals[0]].name), ..."
            cell.textLabel!.text = vitals
        default:
            return cell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    // MARK: Client and vital selection delegate
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToClientSelection" {
            let clientSelection = segue.destination as! ClientSelectionTableViewController
            clientSelection.delegate = self
        }
        else if segue.identifier == "goToVitalSelection" {
            let vitalSelection = segue.destination as! VitalSelectionTableViewController
            vitalSelection.delegate = self
            vitalSelection.options = measurementTypes
            vitalSelection.selected = selectedVitals
        }
    }
    
    func clientSelectionResponse(client: Client) {
        selectedClient = client
        tableView.reloadData()
    }
    
    func vitalSelectionResponse(selected: [Int]) {
        selectedVitals = selected
        tableView.reloadData()
    }
    
    func setupMeasurements() {
        selectedVitals.forEach { sv in
            let measurement = Measurement()
            if let clientId = selectedClient?._id {
                measurement.clientId = clientId
            }
            
            measurement.measurementTypeId = measurementTypes[sv]._id
            measurementTypes[sv].sections.forEach { s in
                let msv = MeasurementSectionValue()
                msv.section = s
                measurement.values.append(msv)
            }
            measurements.append(measurement)
        }
        print(measurements)
    }
    
    func retrieveMeasurementTypesAndSections() {
        interactor.getMeasurementTypes{ (types, err) in
            if(err == nil){
                self.measurementTypes = types!
            } else {
                let alert = UIAlertController(title: "Error", message: err, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
                })
                
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func saveMeasurements(){//(callback: @escaping (_ success: Bool, _ err: String) -> Void) {
        if let clientNumber = selectedClient?.clientNumber {
            interactor.postMeasurements(clientNumber: clientNumber, measurements: measurements) { success, err in
                if success {
                    print("Successfully saved")
                    self.changeProgressHudStatus(progressValue: 1.0, withStatus: "Succesvol opgeslagen")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.progressHUD.hide(true)
                    }
                } else {
                    print("Failed save")
                }
            }
        }
    }
    
    @IBAction func startMeasurementButtonPressed(_ sender: Any) {
        if selectedClient == nil {
            showAlert(title: "Er ging iets mis", message: "Selecteer een cliënt")
        } else if selectedVitals.isEmpty {
            showAlert(title: "Er ging iets mis", message: "Selecteer een of meerdere meting types")
        } else {
            if(bluetoothState == .poweredOn) {
                manager?.scanForPeripherals(withServices: nil, options: nil)
                progressHUD.show(true)
            } else {
                showBluetoothOffError()
            }
            setupMeasurements()
        }
        
        //TODO: Post measurements
//        selectedVitals.removeAll()
    }
    
    // MARK: Bluetooth - Central Manager
    
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
            case .poweredOn:
                print("Bluetooth status is POWERED ON")
            default: break
        }
        bluetoothState = central.state
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Name: \(peripheral.name ?? "")")
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
            self.newWear = peripheral
            self.newWear.delegate = self
            
            manager.stopScan()
            manager.connect(self.newWear, options: nil)
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
    
    // MARK: Bluetooth - Peripheral
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let servicePeripherals = peripheral.services as [CBService]!
        {
            for service in servicePeripherals{
                print("Service uuid: \(service.uuid)")
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        self.service = service
        
        if let characteristicArray = service.characteristics as [CBCharacteristic]!
        {
            for cc in characteristicArray{
                print("UUID ", cc.uuid.uuidString)

                // 00003: TX for reading values, 00002: RX for writing values
                if cc.uuid.uuidString == "6E400003-B5A3-F393-E0A9-E50E24DCCA9E" {
                    read = cc
                    peripheral.setNotifyValue(true, for: cc)
                }
                if cc.uuid.uuidString == "6E400002-B5A3-F393-E0A9-E50E24DCCA9E" {
                    write = cc
                }
            }
            if progressHUD.progress != 0.95 {
                print("Measuring")
                changeProgressHudStatus(progressValue: 0.10, withStatus: "Meting wordt uitgevoerd")
            }
        }
        writeToCharacteristic()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        print("Value written")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print(setup)
        
        if currentIndex < selectedVitals.count {
            var current = measurementTypes[selectedVitals[currentIndex]]
            changeProgressHudStatus(progressValue: Double(setup) / 10, withStatus: "\(current.name) wordt gemeten")
        
            switch characteristic.uuid {
            case CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"):
                if setup > 10 {
                    switch(current.identifier) {
                    case "heartrate":
                        let bpm = heartRate(from: characteristic)
                        print(bpm)
                        measurements.first { m in
                            m.measurementTypeId == current._id
                        }?.values[0].value = String(bpm)
                        
                        nextVital()
                    case "bloodpressure":
                        print("TODO: Bloodpressure")
                        nextVital()
                    default:
                        print("TODO: The rest")
                    }
                }
                setup += 1
            default:
                print("Unhandled Characteristic UUID: \(characteristic.uuid)")
            }
        }
    }
    
    func nextVital() {
        // Go to next measurement
        currentIndex += 1
        if currentIndex < selectedVitals.count {
            writeToCharacteristic()
            setup = 0
        } else {
            changeProgressHudStatus(progressValue: 0.5, withStatus: "Gegevens worden opgeslagen")
            saveMeasurements()
        }
    }
    
    func writeToCharacteristic() {
        if self.service == nil || self.newWear == nil {
            showAlert(title: "Er ging iets mis", message: "Connectie verloren")
        } else {
            let data = measurementTypes[selectedVitals[currentIndex]].bytes
            newWear.writeValue(Data(data), for: write!, type: .withResponse)
        }
    }
    
    // MARK: View
    
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
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
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
    
//    @objc func willEnterForeground(_ notification: NSNotification!) {
//        timeOutRunning = false
//        manager?.scanForPeripherals(withServices: nil, options: nil)
//    }
    
    // MARK: Calculation
    
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
}

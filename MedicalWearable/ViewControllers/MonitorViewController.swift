//
//  BloodPressureViewController.swift
//  MedicalWearable
//
//  Created by Danny Janssen on 27/11/2018.
//  Copyright © 2018 DannyJanssen. All rights reserved.
//q

import UIKit
import SnapKit

class MonitorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ClientSelectionDelegate, MeasurementTakerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startMeasurementButton: UIButton!
    
    private let interactor = MeasurementInteractor()
    private let measurementTaker = MeasurementTaker()
    private var selectedClient: Client?
    
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
        setConstraints()
        
        measurementTaker.delegate = self
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Cliënt"
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "goToClientSelection", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClientCell", for: indexPath)
        let selected = selectedClient != nil
            ? "\(selectedClient!.lastName), \(selectedClient!.name)"
            : "Geen cliënt geselecteerd"
        cell.textLabel!.text = selected
        cell.textLabel!.textColor = UIColor.flatGrayColorDark()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let clientSelection = segue.destination as! ClientSelectionTableViewController
        clientSelection.delegate = self
    }
    
    func clientSelectionResponse(client: Client) {
        selectedClient = client
        tableView.reloadData()
    }
    
    func finishedMeasuring(measurements: [Measurement]) {
        // Send measurements to API
        print(measurements)
    }
    
    
    @IBAction func startMeasurementButtonPressed(_ sender: Any) {
        interactor.getMeasurementsByClient{ (measurements, error) in
            print(measurements!)
            
            self.interactor.postMeasurements(measurements: measurements!) { error in
                print(error)
            }
        }
    }
}

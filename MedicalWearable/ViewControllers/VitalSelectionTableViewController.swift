//
//  VitalSelectionTableViewController.swift
//  MedicalWearable
//
//  Created by Danny Janssen on 11/02/2019.
//  Copyright © 2019 DannyJanssen. All rights reserved.
//

import UIKit

class VitalSelectionTableViewController: UITableViewController {
    
    var delegate: VitalSelectionDelegate?
    var selected: [Int] = []
    var options: [MeasurementType]!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VitalSelectionCell", for: indexPath)
        cell.textLabel!.text = options[indexPath.row].name
        
        if selected.contains(indexPath.row) {
            cell.accessoryType = .checkmark
//            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .bottom)
        } else {
            cell.accessoryType = .none
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            print(indexPath.row)
            if selected.contains(indexPath.row) {
                cell.accessoryType = .none
                selected.remove(at: selected.index(of: indexPath.row)!)
            } else  {
                cell.accessoryType = .checkmark
                selected.append(indexPath.row)
            }
//            cell.accessoryType = cell.accessoryType == .checkmark ? .none : .checkmark
            print(selected)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.delegate?.vitalSelectionResponse(selected: selected)
    }
}

protocol VitalSelectionDelegate {
    func vitalSelectionResponse(selected: [Int])
}

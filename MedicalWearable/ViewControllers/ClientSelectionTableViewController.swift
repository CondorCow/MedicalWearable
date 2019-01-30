//
//  ClientSelectionTableViewController.swift
//  MedicalWearable
//
//  Created by Danny Janssen on 28/01/2019.
//  Copyright © 2019 DannyJanssen. All rights reserved.
//

import UIKit

class ClientSelectionTableViewController: UITableViewController {

    var delegate: ClientSelectionDelegate?
    private let interactor = MeasurementInteractor()
    private var clients: [Client] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadClients()
    }
    
    func loadClients() {
        interactor.getClients{ (c, error) in
            if error == nil {
                self.clients = c! as [Client]
                self.tableView.reloadData()
            } else {
                // Show error alert
                let alert = UIAlertController(title: "Something went wrong.", message: error, preferredStyle: .alert)
                let dismiss = UIAlertAction(title: "OK", style: .default) { _ in
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(dismiss)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clients.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClientSelectionCell", for: indexPath)
        cell.textLabel!.text = "\(clients[indexPath.row].lastName), \(clients[indexPath.row].name)"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.clientSelectionResponse(client: clients[indexPath.row])
        navigationController?.popViewController(animated: true)
    }
}

protocol ClientSelectionDelegate {
    func clientSelectionResponse(client: Client)
}

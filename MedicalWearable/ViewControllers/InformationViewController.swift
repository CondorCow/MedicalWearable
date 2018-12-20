//
//  InformationViewController.swift
//  MedicalWearable
//
//  Created by Danny Janssen on 05/12/2018.
//  Copyright © 2018 DannyJanssen. All rights reserved.
//

import UIKit

class InformationViewController: UITableViewController {
    
    private var informationItems : [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        informationItems.append("Unit4 Zorgapp")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return informationItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InformationCell", for: indexPath)
        cell.textLabel!.text = informationItems[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

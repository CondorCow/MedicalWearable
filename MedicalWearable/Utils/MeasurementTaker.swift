//
//  MeasurementTaker.swift
//  MedicalWearable
//
//  Created by Danny Janssen on 30/01/2019.
//  Copyright © 2019 DannyJanssen. All rights reserved.
//

import Foundation
import CoreBluetooth

class MeasurementTaker: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var delegate: MeasurementTakerDelegate?
    
    func startMeasurement(callback: (_ error: String?) -> Void) {
        // Whatever goes wrong during connecting, throw as error
    }
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
}

// Delegate to return all taken measurements to the MonitorViewController
// It can send the results to the API afterwards
protocol MeasurementTakerDelegate {
    func finishedMeasuring(measurements: [Measurement])
}

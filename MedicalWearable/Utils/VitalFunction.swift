//
//  VitalFunction.swift
//  MedicalWearable
//
//  Created by Danny Janssen on 07/02/2019.
//  Copyright © 2019 DannyJanssen. All rights reserved.
//

import Foundation

class VitalFunction {
    var type: VitalFunctionType
    var bytes: [UInt8]
    var beingMeasured: Bool
    
    init(type: VitalFunctionType, bytes: [UInt8]) {
        self.type = type
        self.bytes = bytes
        self.beingMeasured = false
    }
}

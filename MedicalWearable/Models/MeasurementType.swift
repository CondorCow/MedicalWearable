//
//  MeasurementType.swift
//  MedicalWearable
//
//  Created by Danny Janssen on 30/01/2019.
//  Copyright © 2019 DannyJanssen. All rights reserved.
//

import Foundation
import ObjectMapper

class MeasurementType: NSObject, Mappable {
    var _id: String = ""
    var identifier: String = ""
    var name: String = ""
    var sections: [MeasurementSection] = []
    
    var bytes: [UInt8] = []
    
    override init(){super.init()}
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        _id         <- map["_id"]
        identifier  <- map["identifier"]
        name        <- map["name"]
        sections    <- map["sections"]
        
        switch(identifier.lowercased()) {
        case "heartrate":
            bytes = Variables.heartRateVital
        case "bloodpressure":
            bytes = Variables.bloodPressureVital
        default:
            bytes = Variables.heartRateVital
        }
    }
}

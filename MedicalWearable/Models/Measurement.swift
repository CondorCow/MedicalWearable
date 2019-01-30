//
//  Measurement.swift
//  MedicalWearable
//
//  Created by Danny Janssen on 30/01/2019.
//  Copyright © 2019 DannyJanssen. All rights reserved.
//

import Foundation
import ObjectMapper

class Measurement: Mappable {
    
    var _id: String = ""
    var measurementTypeId: String = ""
    var recordedAt: Date?// = Date()
    var recordedById: String = ""
    var clientId: String = ""
    var values: [MeasurementSectionValue] = []
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        _id             <- map["_id"]
        measurementTypeId <- map["measurementType"]
        recordedById    <- map["recordedBy"]
        clientId        <- map["client"]
        values          <- map["values"]
        
//        var dateFormatter = DateFormatter(withFormat: "yyyy-MM-dd'T'HH:mm:ss", locale: "nl_NL")
//        if let dateString = map["recordedAt"].currentValue as? String {
//            let _date = dateFormatter.date(from: dateString)
//            recordedAt = _date
//        }
    }
}

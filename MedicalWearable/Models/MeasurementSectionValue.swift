//
//  MeasurementSectionValue.swift
//  MedicalWearable
//
//  Created by Danny Janssen on 30/01/2019.
//  Copyright © 2019 DannyJanssen. All rights reserved.
//

import Foundation
import ObjectMapper

class MeasurementSectionValue: Mappable {
    
    var _id: String = ""
    var section: MeasurementSection?
    var value: String = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        _id     <- map["_id"]
        
        let transform = TransformOf<String, Int>(fromJSON: { (value: Int?) -> String? in
            // transform value from String? to Int?
            return String(value!)
        }, toJSON: { (value: String?) -> Int? in
            // transform value from Int? to String?
            if let value = value {
                return Int(value)
            }
            return nil
        })
        value   <- (map["value"], transform)
        section <- map["section"]
    }
    
}

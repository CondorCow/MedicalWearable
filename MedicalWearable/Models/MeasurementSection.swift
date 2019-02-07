//
//  MeasurementSection.swift
//  MedicalWearable
//
//  Created by Danny Janssen on 30/01/2019.
//  Copyright © 2019 DannyJanssen. All rights reserved.
//

import Foundation
import ObjectMapper

class MeasurementSection: NSObject, Mappable {
    var _id: String = ""
    var name: String = ""
    
    override init() {super.init()}
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        _id     <- map["_id"]
        name    <- map["name"]
    }
    
}

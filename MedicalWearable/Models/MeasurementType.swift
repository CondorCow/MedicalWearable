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
    var name: String = ""
    var sections: [MeasurementSection] = []
    
    override init(){super.init()}
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
    }
}

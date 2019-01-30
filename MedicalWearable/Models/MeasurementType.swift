//
//  MeasurementType.swift
//  MedicalWearable
//
//  Created by Danny Janssen on 30/01/2019.
//  Copyright © 2019 DannyJanssen. All rights reserved.
//

import Foundation
import ObjectMapper

class MeasurementType: Mappable {
    var name: String = ""
    var sections: [MeasurementSection] = []
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
    }
}

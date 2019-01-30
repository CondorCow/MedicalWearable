//
//  Client.swift
//  MedicalWearable
//
//  Created by Danny Janssen on 28/01/2019.
//  Copyright © 2019 DannyJanssen. All rights reserved.
//

import Foundation
import ObjectMapper

class Client : Mappable{
    var _id: String = ""
    var clientNumber: Int = 0
    var name: String = ""
    var lastName: String = ""
    var address: String = ""
    var postalCode: String = ""
    var city: String = ""
    var telephone: String = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        _id             <- map["_id"]
        clientNumber    <- map["clientNumber"]
        name            <- map["name"]
        lastName        <- map["lastName"]
        address         <- map["address"]
        postalCode      <- map["postalCode"]
        city            <- map["city"]
        telephone       <- map["telephone"]
    }
}

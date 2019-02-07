//
//  MeasurementSectionValue.swift
//  MedicalWearable
//
//  Created by Danny Janssen on 30/01/2019.
//  Copyright © 2019 DannyJanssen. All rights reserved.
//

import Foundation
import ObjectMapper

class MeasurementSectionValue: NSObject, Mappable {
    
    var _id: String = ""
    var section: MeasurementSection?
    var value: String = ""
    
    override init() {super.init()}
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        _id     <- map["_id"]
        
        let transform = TransformOf<String, Int>(fromJSON: { (value: Int?) -> String? in
            return String(value!)
        }, toJSON: { value in
            if let value = value {
                return Int(value)
            }
            return nil
        })
        value   <- (map["value"], transform)

        if(map.mappingType == MappingType.toJSON) {
            let sectionTransform = TransformOf<MeasurementSection, String>(fromJSON: {(value: String?) -> MeasurementSection? in
                return nil
            }, toJSON: { (section: MeasurementSection?) -> String? in
                return section!._id
            })
            section <- (map["sectionId"], sectionTransform)
        } else {
            section <- map["section"]
        }
    }
    
}

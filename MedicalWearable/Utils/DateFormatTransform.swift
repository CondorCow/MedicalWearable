//
//  DateFormatTransform.swift
//  MedicalWearable
//
//  Created by Danny Janssen on 30/01/2019.
//  Copyright © 2019 DannyJanssen. All rights reserved.
//

import Foundation
import ObjectMapper

public class DateFormatTransform: TransformType {
    
    public typealias Object = Date
    public typealias JSON = String
    
    var dateFormatter = DateFormatter(withFormat: "yyyy-MM-dd HH:mm:ss", locale: "nl_NL")
    
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormatter = DateFormatter(withFormat: dateFormat, locale: "nl_NL")
    }
    
    public func transformFromJSON(_ value: Any?) -> Date? {
        if let dateString = value as? String {
            return self.dateFormatter.date(from: dateString)
        }
        return nil
    }
    
    public func transformToJSON(_ value: Date?) -> String? {
        if let date = value {
            return self.dateFormatter.string(from: date)
        }
        return nil
    }
    
}

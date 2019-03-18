//
//  Variables.swift
//  MedicalWearable
//
//  Created by Danny Janssen on 24/01/2019.
//  Copyright © 2019 DannyJanssen. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

struct Variables {
    //INDICIA
//    static var API_URL: String = "http://192.168.254.236:3000/"
    
    //THUIS
    static var API_URL: String = "http://192.168.178.73:3000/"
    
    static var heartRateVital: [UInt8] = [0x69, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,0x00,0x00,0x00,0x00, 0x6A]
    static var bloodPressureVital: [UInt8] = [0x69, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,0x00,0x00,0x00,0x00, 0x6B]
    
    static func isPincodeSet() -> Bool {
        return (KeychainWrapper.standard.string(forKey: "pincode") != nil)
    }
}

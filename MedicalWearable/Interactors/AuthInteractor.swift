//
//  LoginInteractor.swift
//  MedicalWearable
//
//  Created by Danny Janssen on 24/01/2019.
//  Copyright © 2019 DannyJanssen. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper

class AuthInteractor {
    func login(_ email: String, _ password: String, callback: @escaping (_ success: Bool, _ title: String?, _ message: String?) -> Void) {
        let api_url = Variables.API_URL + "auth/login"
        
        let params = [
            "email": email,
            "password": password
        ]
        Alamofire.request(api_url, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            switch(response.result){
            case .success:
                guard let statusCode = response.response?.statusCode else {
                    return
                }
                
                if let data = response.data{
                    do {
                        let responseJson = try JSON(data: data)
                        print(responseJson)
                        if(statusCode ==  200) {
                            let saveSuccessful: Bool = KeychainWrapper.standard.set(responseJson["token"].stringValue, forKey: "token")
                            print("Save was successful")
                            callback(true, nil, nil)
                        } else {
                            callback(false, responseJson["message"].stringValue, responseJson["data"][0]["msg"].stringValue)
                        }
                    } catch {
                        callback(false, "Something went wrong.", "")
                    }
                }
                
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    func logout(_ callback: (_ success: Bool) -> Void) {
        callback(true)
    }
}

//
//  MeasurementInteractor.swift
//  MedicalWearable
//
//  Created by Danny Janssen on 28/01/2019.
//  Copyright © 2019 DannyJanssen. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftKeychainWrapper
import Alamofire
import ObjectMapper

class MeasurementInteractor {
    
    func getClients(callback: @escaping ([Client]?, _ error: String?) -> Void) {
    
        if let token = getToken() {
            let headers = [
                "Authorization": "Bearer \(token)"
            ]
            let api_url = Variables.API_URL + "client/all"
            
            Alamofire.request(api_url, method: .get, headers: headers).responseJSON{ response in
                guard let data = response.data else {
//                    callback(false, nil)
                    return
                }
                do {
                    let responseJson = try JSON(data)["clients"].rawValue
                    let clientArray = Mapper<Client>().mapArray(JSONArray: responseJson as! [[String: Any]])
                    callback(clientArray, nil)
                } catch {
                    
                }
            }
        } else {
            callback(nil, "Not authorized.")
        }
    }
    
    func getMeasurementTypes(callback: @escaping ([MeasurementType]?, _ error: String?) -> Void) {
        if let token = getToken() {
            let headers = [
                "Authorization": "Bearer \(token)"
            ]
            let api_url = Variables.API_URL + "admin/measurementTypes"
            
            Alamofire.request(api_url, method: .get, headers: headers).responseJSON{ response in
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
                                let responseJson = JSON(data)["measurementTypes"].rawValue
                                let measurementTypes = Mapper<MeasurementType>().mapArray(JSONArray: responseJson as! [[String: Any]])
                                callback(measurementTypes, nil)
                            } else {
                                callback(nil, responseJson["message"].stringValue)//, responseJson["data"][0]["msg"].stringValue)
                            }
                        } catch {
                            callback(nil, "Something went wrong")
                        }
                    }
                case .failure(let error):
                    print(error)
                    callback(nil, error.localizedDescription)
                    break
                }
            }
        } else {
            callback(nil, "Not authorized.")
        }
    }
    
    func getMeasurementsByClient(callback: @escaping ([Measurement]?, _ error: String?) -> Void){
        if let token = getToken() {
            let headers = [
                "Authorization": "Bearer \(token)"
            ]
            
            //TODO: Get from specific client
            let api_url = Variables.API_URL + "client/measurement/1006"
            
            Alamofire.request(api_url, method: .get, headers: headers).responseJSON{ response in
                guard let data = response.data else {
                    return
                }
                do {
                    let responseJson = JSON(data)["measurements"].rawValue
                    let measurementArray = Mapper<Measurement>().mapArray(JSONArray: responseJson as! [[String: Any]])
                    callback(measurementArray, nil)
                } catch {
                    
                }
            }
        } else {
            callback(nil, "Not authorized.")
        }
    }
    
    func postMeasurements(clientNumber: Int, measurements: [Measurement], callback: @escaping (_ success: Bool, _ error: String?) -> Void) {
        if let token = getToken() {
            let api_url = Variables.API_URL + "client/\(clientNumber)/measurements"
            
            let json = measurements.toJSON()
            let data = try! JSONSerialization.data(withJSONObject: json)
            
            var request = URLRequest(url: URL(string: api_url)!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = "POST"
            request.httpBody = data
            Alamofire.request(request).responseJSON { response in
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
                                callback(true, nil)
                            } else {
                                callback(false, responseJson["message"].stringValue)
                            }
                        } catch {
                            callback(false, "Something went wrong")
                        }
                    }

                case .failure(let error):
                    print(error)
                    callback(false, error.localizedDescription)
                    break
                }
            }
        }
    }
    
    private func getToken() -> String? {
        return KeychainWrapper.standard.string(forKey: "token")
    }
}

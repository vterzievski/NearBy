//
//  NetworkManager.swift
//  NearByApp
//
//  Created by Vladimir Terzievski on 9/1/20.
//  Copyright © 2020 Vladimir Terzievski. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreLocation

typealias Completion = (_ nearByLocations:[NearByLocations]?, _ error: Error?) -> ()


class NetworkManager {
    static let shared = NetworkManager()
    
    let clientId = "JHMCITVHUKBHVIX3DY0ZBPELGTHJGBLS1VIYR0JLRWOD2KF2"
    let clientSickret = "APDN240OI3S4R0IW5PZXGQ5M3TYLOK3J0VXG3RVYPG5LCZHO"
        
    func makeApiCall(cordinates:CLLocation, completion: @escaping Completion) {
        
        let cordinatesString = "\(cordinates.coordinate.latitude)" + "," + "\(cordinates.coordinate.longitude)"
       
        
        var parsedLocations:[NearByLocations] = []
        
        let urlString = String(format: "https://api.foursquare.com/v2/venues/explore?ll=%@&client_id=%@&client_secret=%@&v=20180323", cordinatesString,clientId,clientSickret)
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            // request.httpBody = try! JSONSerialization.data(withJSONObject: params)
            
            
            
            Alamofire.request(request).responseJSON { (response) in
                if let error = response.error {
                    debugPrint(error)
                    completion(nil,error)
                    return
                }
                
                if let _ = response.result.value {
                    if let data = response.data {
                        if let json = try? JSON(data: data) {
                            let responseString = json["response"]
                            let groups = responseString["groups"].array
                            
                            if let firstObject = groups?.first {
                                if let items = firstObject["items"].array {
                                    for venue in items {
//                                        debugPrint(venue["venue"]["name"])
                                        
                                        let location = NearByLocations()
                                        
                                        if let name = venue["venue"]["name"].string {
                                            location.name = name
                                        }
                                        if let address = venue["venue"]["location"]["address"].string {
                                            location.address = address
                                        }
                                        
                                        if let categories = venue["venue"]["categories"].array {
                                            if let category = categories.first {
                                                if let photoPrefix = category["icon"]["prefix"].string {
                                                    location.photoPrefix = photoPrefix
                                                }
                                                if let photoSuffix = category["icon"]["suffix"].string {
                                                    location.photoSuffix = photoSuffix
                                                }
                                                if let id = category["id"].string {
                                                    location.photoId = id
                                                }
                                            }
                                        }
                                        
                                        parsedLocations.append(location)
                                    }
                                }
                            }
                        }
                    }
                }
                
                completion(parsedLocations,nil)
            }
        }
    }
}

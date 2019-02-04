//
//  GeocodingService.swift
//  Produce Pal
//
//  Created by Noah Woodward on 2/2/19.
//  Copyright © 2019 Noah Woodward. All rights reserved.
//

import Foundation
import enum Result.Result
import Alamofire
import SwiftyJSON

struct GeocodingService{
    
    /**
     Returns a list of updated Markets with latitude and longitude values to be used with MapKit annotations.
     
     - Parameter *inout(mutatable)* Markets: A list of incomplete markets that have an adress to be used
     
     - Parameter completion: A completion handler to take in whether the result was successful or not
     
     - Returns: A completion with either an array of complete markets or an error.
     */
    static func getLocationInfo(market: Market, completion: @escaping((Result<Market,ProdError>) -> Void)){
        guard let marketLocation = market.location else {
            return completion(.failure(ProdError.FailedAPICall("No Address given")))
        }
        let trimmedString = marketLocation.removeWhitespace()
        print(trimmedString)
        let url = "https://maps.googleapis.com/maps/api/geocode/json?address=\(trimmedString)&key=AIzaSyBukvkKCjPymdoa0MJk4GOmuk5iDxrQEEo"
        Alamofire.request(url, method: .get).responseJSON { response in
            switch response.result {
            case .success:
                print("API call success")
                let json: JSON = JSON(response.result.value!)
                let results = json["results"][0]["geometry"]["location"]
                let lng = results["lng"].double
                let lat = results["lat"].double
                var marketCopy = market
                if let lngUnwrapped = lng, let latUnwrapped = lat {
                    marketCopy.lat = latUnwrapped
                    marketCopy.lon = lngUnwrapped
                }else {
                    marketCopy.lat = nil
                    marketCopy.lon = nil
                }
                

                return completion(.success(marketCopy))
            case .failure(let error):
                print("Error:\(error)")
                return completion(.failure(ProdError.FailedAPICall(error.localizedDescription)))
                
                
            }
        }
    }
}

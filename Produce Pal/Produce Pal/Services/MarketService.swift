//
//  MarketService.swift
//  Produce Pal
//
//  Created by Noah Woodward on 1/31/19.
//  Copyright © 2019 Noah Woodward. All rights reserved.
//

import Foundation
import enum Result.Result
import Alamofire
import SwiftyJSON

struct MarketService{
    
    static func getMarketIDs(zip: String,completion: @escaping (Result<[String],ProdError>) -> Void) {
        let url = APIConstants.baseURL + zip
        Alamofire.request(url, method: .get).responseJSON { response in
            switch response.result {
            case .success:
                print("API call success")
                let json: JSON = JSON(response.result.value!)
                let resultsArray = json["results"]
                guard let array = resultsArray.array else{
                    print("No Array in the JSON response")
                    return completion(.failure(ProdError.KeyDoesNotExist("There was an error with the key")))
                }
                var marketIDs = [String]()
                for jsonObj in array{
                    let id = jsonObj["id"].string
                    guard let safeID = id else {fatalError("No ID")}
                    marketIDs.append(safeID)
                    
                }
                return completion(.success(marketIDs))
            case .failure(let error):
                print("Error:\(error)")
                return completion(.failure(ProdError.FailedAPICall(error.localizedDescription)))
                
                
            }
        }
    }
}

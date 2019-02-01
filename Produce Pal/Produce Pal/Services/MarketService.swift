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
    
    /**
     Gets a list of Markets with only the required attributes stored(id,name).
     
     - Parameter zip: A zip code to be used for the API request for where the user wants to get farmers markets.
     
     - Parameter completion: A completion handler to take in whether the result was successful or not
     
     - Returns: A completion with either an array of markets or an error.
     */
    
    static func getMarkets(zip: String,completion: @escaping (Result<[Market],ProdError>) -> Void) {
        let url = APIConstants.baseIdURL + zip
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
                var markets = [Market]()
                for jsonObj in array{
                    guard let market = Market(json: jsonObj) else {fatalError("No Market returned back")}
                    markets.append(market)
                }
                return completion(.success(markets))
            case .failure(let error):
                print("Error:\(error)")
                return completion(.failure(ProdError.FailedAPICall(error.localizedDescription)))
                
                
            }
        }
    }
    
    
    
    /**
     Gets a list of Markets with market information filled out enough to be used on the map.
     
     - Parameter Market: A passed in incomplete market, that will be made a copy of to complete.
     
     - Parameter completion: A completion handler to take in whether the result was successful or not
     
     - Returns: A completion with either a market or an error.
     */
    
    static func getMarketInformation(market: Market,completion: @escaping (Result<Market,ProdError>) -> Void) {
        let url = APIConstants.baseInfoURL + market.id
        Alamofire.request(url, method: .get).responseJSON { response in
            switch response.result {
            case .success:
                print("API for Information success")
                let json: JSON = JSON(response.result.value!)
                var marketDetails = json["marketdetails"]
                var resultMarket = market
                resultMarket.location = marketDetails["Address"].string
                resultMarket.products = marketDetails["Products"].string
                resultMarket.location = marketDetails["Address"].string
                resultMarket.time = marketDetails["Schedule"].string
                print(resultMarket)
                return completion(.success(resultMarket))
            case .failure(let error):
                print("Error:\(error)")
                return completion(.failure(ProdError.FailedAPICall(error.localizedDescription)))
                
                
            }
        }
    }
    
    
    
}

//
//  Market.swift
//  Produce Pal
//
//  Created by Noah Woodward on 1/31/19.
//  Copyright © 2019 Noah Woodward. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Market{
    var id: String
    var name: String
    var location: String?
    var googleLink: String?
    var time: String?
    var products: String?
    var lat: Double?
    var lon: Double?
    
    
    init(id: String, name: String){
        self.id = id
        self.name = name
    }
    
    init?(json: JSON){
        guard
        let id = json["id"].string,
        let name = json["marketname"].string
            else {
                return nil
        }
        self.id = id
        self.name = name
    }
}

//
//  ProdError.swift
//  Produce Pal
//
//  Created by Noah Woodward on 1/31/19.
//  Copyright © 2019 Noah Woodward. All rights reserved.
//

import Foundation

enum ProdError: Error {
    case KeyDoesNotExist(String)
    case FailedAPICall(String)
}

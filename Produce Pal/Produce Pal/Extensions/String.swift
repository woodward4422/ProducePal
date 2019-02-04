//
//  String.swift
//  Produce Pal
//
//  Created by Noah Woodward on 2/3/19.
//  Copyright © 2019 Noah Woodward. All rights reserved.
//

import Foundation


extension String {
    func replace(string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(string: " ", replacement: "+")
    }
}

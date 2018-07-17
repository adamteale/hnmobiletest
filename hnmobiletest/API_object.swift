//
//  API_object.swift
//  hnmobiletest
//
//  Created by adam on 7/17/18.
//  Copyright © 2018 adam. All rights reserved.
//

import Foundation

struct API_object {
    
    var hits : [Hit]

    //implement other parameters
    
}

extension API_object: Decodable {

    enum API_objectStructKeys: String, CodingKey {
        // declaring the keys
        case hits = "hits"
    }
    
    init(from decoder: Decoder) throws {
        // defining our (keyed) container
        let container = try decoder.container(keyedBy: API_objectStructKeys.self)
        
        // extracting the data
        let hits: [Hit] = try container.decode([Hit].self, forKey: .hits)
        
        self.init(hits: hits)
    }
}

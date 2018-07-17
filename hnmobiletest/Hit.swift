//
//  Post.swift
//  hnmobiletest
//
//  Created by adam on 7/17/18.
//  Copyright © 2018 adam. All rights reserved.
//

import Foundation

struct Hit {
    
    var created_at : String
    var title : String
    //implement other parameters

}

extension Hit: Decodable {
    
    enum HitStructKeys: String, CodingKey {
        // declaring the keys
        case created_at = "created_at"
        case title = "title"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: HitStructKeys.self) // defining our (keyed) container

        let created_at: String = try container.decode(String.self, forKey: .created_at) // extracting the data
        let title: String = try container.decode(String.self, forKey: .title) // extracting the data

        self.init(created_at: created_at, title: title) // initializing our struct
    }
}

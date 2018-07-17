//
//  API_request.swift
//  hnmobiletest
//
//  Created by adam on 7/17/18.
//  Copyright © 2018 adam. All rights reserved.
//

import Foundation


class API_request
{
   
    func jsonResponseAsNSDictionary(_ completionHandler: @escaping (_ response: API_object) -> ()) {
        
//        let api_urlstring = "http://hn.algolia.com/api/v1/search_by_date?query=ios"
        let api_urlstring = "https://jsonblob.com/be774856-8a13-11e8-a006-5f824ca66318"
        
        guard let url = URL(string: api_urlstring) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }

            //Implement JSON decoding and parsing
            do {

                //Decode retrieved data with JSONDecoder and assing type of Hit object

                // decoding our data
                let api_object_struct = try JSONDecoder().decode(API_object.self, from: data)
                print(api_object_struct)

                completionHandler(api_object_struct)
                
                
            } catch let jsonError {
                print(jsonError)
            }
            
        }.resume()
        
    }
    
}

//
//  Hit.swift
//  hnmobiletest
//
//  Created by Adam Teale on 18/7/18.
//  Copyright © 2018 adam. All rights reserved.
//

import Foundation

struct Hit : Codable{
  
  var created_at : String?
  var title : String?
  var url : URL?
  var author : String?
  var points : String?
  var story_text : String?
  var comment_text : String?
  var num_comments : Int?
  var story_id : Int?
  var story_title : String?
  var story_url : URL?
  var parent_id : Int?
  var created_at_i : Int?
  var _tags : [String]?
  var objectID : String?
  var _highlightResult : HighLightedResult?
  
  
}


extension Hit: Hashable, Equatable {
  var hashValue:Int { return "\(String(describing: self.story_id)),\(String(describing: self.story_id))".hashValue }
}

func ==(lhs: Hit, rhs: Hit) -> Bool {
  return lhs.story_id == rhs.story_id
}

func >(lhs: Hit, rhs: Hit) -> Bool {
  let dateFormatterGet = DateFormatter()
  dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
  let dateA: Date? = dateFormatterGet.date(from: lhs.created_at! )
  let dateB: Date? = dateFormatterGet.date(from: rhs.created_at! )

  return dateA! > dateB!
}

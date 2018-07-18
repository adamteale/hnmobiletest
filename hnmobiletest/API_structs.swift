//
//  HighlightedResult.swift
//  hnmobiletest
//
//  Created by Adam Teale on 17/7/18.
//  Copyright © 2018 adam. All rights reserved.
//

import Foundation

struct API_object: Decodable {
  
  var hits : [Hit]?
  var nbHits : Int?
  var page : Int?
  var nbPages : Int?
  var hitsPerPage : Int?
  var processingTimeMS : Int?
  var exhaustiveNbHits : Bool?
  var query : String?
  var params : String?
  
}





struct HighLightedResult : Codable
{
  let author : Author?
  let comment_text : Comment_Text?
  let story_title : Story_Title?
  let story_url : Story_URL?
}

struct Author : Codable
{
  let name : String?
  let matchLevel : String?
  let matchedWords : [String]?
}

struct Comment_Text : Codable
{
  let value : String?
  let matchLevel : String?
  let fullyHighlighted : Bool?
  let matchedWords : [String]?
}

struct Story_Title : Codable
{
  let value : String?
  let matchLevel : String?
  let fullyHighlighted : Bool?
  let matchedWords : [String]?
  
}

struct Story_URL : Codable
{
  let value : String?
  let matchLevel : String?
  let fullyHighlighted : Bool?
  let matchedWords : [String]?

}

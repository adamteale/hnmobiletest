//
//  HighlightedResult.swift
//  hnmobiletest
//
//  Created by Adam Teale on 17/7/18.
//  Copyright © 2018 adam. All rights reserved.
//

import Foundation

struct APIObject: Decodable {
  
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
  enum CodingKeys: String, CodingKey {
    case author
    case commentText = "comment_text"
    case storyTitle = "story_title"
    case storyURL = "story_url"
  }
  
  let author : Author?
  let commentText : Comment_Text?
  let storyTitle : StoryTitle?
  let storyURL : StoryURL?
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

struct StoryTitle : Codable
{
  let value : String?
  let matchLevel : String?
  let fullyHighlighted : Bool?
  let matchedWords : [String]?
  
}

struct StoryURL : Codable
{
  let value : String?
  let matchLevel : String?
  let fullyHighlighted : Bool?
  let matchedWords : [String]?

}

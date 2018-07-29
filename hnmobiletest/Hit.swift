//
//  Hit.swift
//  hnmobiletest
//
//  Created by Adam Teale on 18/7/18.
//  Copyright © 2018 adam. All rights reserved.
//

import Foundation

struct Hit : Codable{
  enum CodingKeys: String, CodingKey {
    case createdAt = "created_at"
    case title
    case url
    case author
    case points
    case storyText = "story_text"
    case commentText = "commentText"
    case numComments = "num_comments"
    case storyID = "story_id"
    case storyTitle = "story_title"
    case storyURL = "story_url"
    case parentID = "parent_id"
    case createdAtI = "created_at_i"
    case tags = "_tags"
    case objectID
    case highlightResult = "_highlightResult"
  }

  let createdAt : String?
  let title : String?
  let url : URL?
  let author : String?
  let points : String?
  let storyText : String?
  let commentText : String?
  let numComments : Int?
  let storyID : Int?
  let storyTitle : String?
  let storyURL : URL?
  let parentID : Int?
  let createdAtI : Int?
  let tags : [String]?
  let objectID : String?
  let highlightResult : HighLightedResult?
}

extension Hit: Hashable, Equatable {
  var hashValue:Int { return "\(String(describing: self.storyID)),\(String(describing: self.storyID))".hashValue }
}

func ==(lhs: Hit, rhs: Hit) -> Bool {
  return lhs.storyID == rhs.storyID
}

func >(lhs: Hit, rhs: Hit) -> Bool {
  let dateFormatterGet = DateFormatter()
  dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
  let dateA: Date? = dateFormatterGet.date(from: lhs.createdAt! )
  let dateB: Date? = dateFormatterGet.date(from: rhs.createdAt! )
  return dateA! > dateB!
}

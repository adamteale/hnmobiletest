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


struct Hit : Decodable{
    
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


struct HighLightedResult : Decodable
{
    let author : Author?
    let comment_text : Comment_Text?
    let story_title : Story_Title?
    let story_url : Story_URL?
}

struct Author : Decodable
{
    let name : String?
    let matchLevel : String?
    let matchedWords : [String]?
}

struct Comment_Text : Decodable
{
    let value : String?
    let matchLevel : String?
    let fullyHighlighted : Bool?
    let matchedWords : [String]?
}

struct Story_Title : Decodable
{
    let value : String?
    let matchLevel : String?
    let fullyHighlighted : Bool?
    let matchedWords : [String]?
    
}

struct Story_URL : Decodable
{
    let value : String?
    let matchLevel : String?
    let fullyHighlighted : Bool?
    let matchedWords : [String]?

}

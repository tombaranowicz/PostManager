//
//  Post.swift
//  Social Manager
//
//  Created by Tomasz Baranowicz on 21/03/16.
//  Copyright © 2016 Direct Solutions. All rights reserved.
//

import Foundation

class Post: NSObject {
    
    var object_id : Int
    var text : String
    var favorite_count : Int?
    var retweet_count : Int?
    var date : NSDate
    var media_path : String?
    
//    var accounts : NSArray
    
    init(dictionary : NSDictionary) {
        
//        print("init post \(dictionary)")
        
        self.object_id = dictionary["id"] as! Int
        self.text = dictionary["text"] as! String
        self.favorite_count = dictionary["favorite_count"] as? Int
        self.retweet_count = dictionary["retweet_count"] as? Int
        
        
        //Wed Mar 30 06:06:55 +0000 2016
        let formatter = NSDateFormatter()
        formatter.dateFormat = "eee MMM dd HH:mm:ss ZZZZ yyyy"
        self.date = formatter.dateFromString(dictionary["created_at"] as! String)!
        
        
        if let entities = dictionary["entities"] as? NSDictionary {
            if let mediaDictionary = entities["media"] as? NSArray {
                self.media_path = mediaDictionary[0]["media_url"] as? String
                
                if let media_url = mediaDictionary[0]["url"] as? String {
                    self.text = self.text.stringByReplacingOccurrencesOfString(media_url, withString: "")
                }
                print("media url \(self.media_path)")
            }
        }
    }
}

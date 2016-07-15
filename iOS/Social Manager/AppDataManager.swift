//
//  AppDataManager.swift
//  Social Manager
//
//  Created by Tomasz Baranowicz on 22/03/16.
//  Copyright © 2016 Direct Solutions. All rights reserved.
//

import UIKit
import Alamofire

class AppDataManager: NSObject {
    
    static let PAGE_SIZE = 10
    
    static func getPostsForActiveAccount(lastId: Int?, callback: (NSMutableArray) -> Void) {
        
        guard (DataManager.activeAccount != nil)
        else {
            callback(NSMutableArray())
            return
        }
        
        let client = OAuthSwiftClient(consumerKey: Twitter["consumerKey"]!, consumerSecret: Twitter["consumerSecret"]!, accessToken: DataManager.activeAccount!.token, accessTokenSecret: DataManager.activeAccount!.secret)
        client.credential.version = .OAuth1
        
        var parameters = Dictionary<String, AnyObject>()
        if let max_id = lastId {
            parameters["max_id"] = max_id
        }
        parameters["count"] = PAGE_SIZE
        client.get("https://api.twitter.com/1.1/statuses/user_timeline.json", parameters: parameters,
            success: {
                data, response in
                let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
                
                let posts = jsonDict as! NSArray
                
                let postsArray : NSMutableArray = NSMutableArray()
                for var dict in posts {
                    postsArray.addObject(Post(dictionary: dict as! NSDictionary))
                }
                
                callback(postsArray)
                
            }, failure: {(error:NSError!) -> Void in
                print("user statuses error\(error.localizedDescription)")
        })
    }
}

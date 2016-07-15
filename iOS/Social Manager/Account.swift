//
//  Account.swift
//  Social Manager
//
//  Created by Tomasz Baranowicz on 16/12/15.
//  Copyright © 2015 Direct Solutions. All rights reserved.
//

import UIKit

enum AccountType {
    case Twitter
    case Facebook
}

class Account: NSObject {

    var login : String?
    var object_id : String
    var type : AccountType
    var token : String
    var secret : String
    var profile_image_url : String?
    var info : NSDictionary?
    
    init(dictionary : NSDictionary) {
        self.token = dictionary[TOKEN_KEY] as! String
        self.secret = dictionary["secret"] as! String
        self.object_id = dictionary["_id"] as! String
        
        if ((dictionary["type"]?.isEqualToString("twitter")) != nil) {
            self.type = .Twitter
        } else {
            self.type = .Facebook
        }
        
        self.login = dictionary["username"] as? String
        self.profile_image_url = dictionary["profile_image_url"] as? String
        self.info = dictionary["info"] as? NSDictionary
    }
}

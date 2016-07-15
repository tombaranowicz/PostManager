//
//  Task.swift
//  Social Manager
//
//  Created by Tomasz Baranowicz on 04/01/16.
//  Copyright © 2016 Direct Solutions. All rights reserved.
//

import UIKit

class Task: NSObject {
    
    var object_id : String
    var message : String
    var media_path : String?
    var date : NSDate
    var accounts : NSArray
    
    init(dictionary : NSDictionary) {
        
//        print("init task \(dictionary)")
        self.object_id = dictionary["_id"] as! String
        self.message = dictionary["message"] as! String
        
        //2016-01-03T17:45:09.000Z
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        self.date = formatter.dateFromString(dictionary["date"] as! String)!
        
        self.accounts = dictionary["accounts"] as! NSArray
        
        if let path = dictionary["media_path"] {
            self.media_path = path as? String
        }
    }
    
    func readableDate() -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        formatter.timeStyle = .ShortStyle
        return "\(formatter.stringFromDate(date))"
    }
}

//
//  DataManager.swift
//  Social Manager
//
//  Created by Tomasz Baranowicz on 14/11/15.
//  Copyright © 2015 Direct Solutions. All rights reserved.
//

import UIKit
import Alamofire
import Google

class DataManager: NSObject {

    static let accounts : NSMutableArray = NSMutableArray()
    static let tasks : NSMutableArray = NSMutableArray()
    static var activeAccount : Account?
    
    static func clearData() {
        tasks.removeAllObjects()
        accounts.removeAllObjects()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(SELECTED_ACCOUNT_ID)
        defaults.synchronize()
    }
    
    static func refreshAccounts(callback: (NSMutableArray) -> Void) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.stringForKey(TOKEN_KEY) != nil {
            let token = defaults.stringForKey(TOKEN_KEY)! as String
            
            let params = [TOKEN_KEY: token]
            print("refresh accounts with params \(params)")
            Alamofire.request(.GET, SERVER_BASE_URL+"/api/user_accounts", parameters: params).responseJSON { response in
                
                if (response.response?.statusCode == 401) {
                    NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_SIGN_OUT, object: nil)
                    self.clearData()
                    return
                }
                
                if let error = response.result.error {
                    print("accounts got error \(error.code) \(response)")
                }

                accounts.removeAllObjects()
                let JSON = response.result.value
                print("got accounts \(JSON)")
                
                if let accountsJson = JSON?["accounts"] {
                    
                    let mySharedDefaults = NSUserDefaults(suiteName: SHARED_DEFAULTS);
                    mySharedDefaults?.setObject(NSKeyedArchiver.archivedDataWithRootObject(accountsJson!), forKey: "accounts")
                    mySharedDefaults?.setObject(token, forKey: "token")
                    mySharedDefaults?.synchronize()
                    
                    var selectedAccountId : String? = defaults.stringForKey(SELECTED_ACCOUNT_ID)
                    
                    let accountsArray = accountsJson as! NSArray
                    for accountDictionary in accountsArray {
                        let account = Account(dictionary: accountDictionary as! NSDictionary)
                        accounts.addObject(account)
                        
                        if selectedAccountId == nil {
                            selectedAccountId = account.object_id
                            activeAccount = account
                        } else if account.object_id == selectedAccountId {
                            activeAccount = account
                        }
                    }
                    
                    if activeAccount == nil && accounts.count>0{
                        activeAccount = accounts[0] as? Account
                    }
                    
                    callback(accounts)
                    NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_ACCOUNTS_REFRESHED, object: nil)
                }
            }
        }
    }
    
    static func accountsWithIds(ids: NSArray, callback:(NSArray) -> Void)  {
        let accounts = NSMutableArray()
        
        for accountId in ids as! [String] {
            for account in DataManager.accounts as NSArray as! [Account] {
                
                if account.object_id.isEqual(accountId) {
                    accounts.addObject(account)
                }
            }
        }
        
        callback(accounts)
    }
    
    static func refreshTasks(callback:(NSArray) -> Void) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.stringForKey(TOKEN_KEY) != nil {
            let token = defaults.stringForKey(TOKEN_KEY)! as String
            
            guard let accountId = DataManager.activeAccount?.object_id
                else {
                    print("no account Id")
                    callback([])
                    return
                }
            
            let params = [TOKEN_KEY: token, "account_id": accountId]
            print("get accounts \(params)")
            
            Alamofire.request(.GET, SERVER_BASE_URL+"/api/account_tasks", parameters: params).responseJSON { response in
                if (response.response?.statusCode == 401) {
                    NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_SIGN_OUT, object: nil)
                    self.clearData()
                    return
                }
                
                if let error = response.result.error {
                    print("tasks got error \(error)")
                }
                
                let JSON = response.result.value
                //print("TASKS: \(JSON)")
                
                tasks.removeAllObjects()
                
                if let arrayJson = JSON?["tasks"] {
                    let array = arrayJson as! NSArray
                    for accountDictionary in array {
                        let task = Task(dictionary: accountDictionary as! NSDictionary)
                        tasks.addObject(task)
                    }
                }
                
                callback(tasks)
            }
        } else {
            callback([])
        }
    }
    
    static func deleteTask(task: Task, callback:(Bool) -> Void)  {
        
        let tracker = GAI.sharedInstance().defaultTracker
        let builder = GAIDictionaryBuilder.createEventWithCategory("delete_task_action", action: "call", label: "", value: 1)
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.stringForKey(TOKEN_KEY) != nil {
            let token = defaults.stringForKey(TOKEN_KEY)! as String
            
            let params = [TOKEN_KEY: token, "task_id": task.object_id]
            
            Alamofire.request(.POST, SERVER_BASE_URL+"/api/delete_task", parameters: params).responseJSON { response in
                if (response.response?.statusCode == 401) {
                    NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_SIGN_OUT, object: nil)
                    self.clearData()
                    return
                }
                
                if let error = response.result.error {
                    print("got error \(error)")
                    callback(false)
                }
               
                callback(true)
            }
        } else {
            callback(false)
        }
    }
    
    static func selectAccount(account: Account) {
        self.activeAccount = account
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(account.object_id, forKey: SELECTED_ACCOUNT_ID)
        defaults.synchronize()
        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_ACCOUNT_SWITCHED, object: nil)
    }
    
    static func schedulePost(selectedAccounts : NSArray, text : String, image : UIImage?, scheduleDate: NSDate, callback:(Bool) -> Void) {
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
//            let defaults = NSUserDefaults.standardUserDefaults()
//            let user_token = defaults.stringForKey(TOKEN_KEY)! as String
            
            let mySharedDefaults = NSUserDefaults(suiteName: SHARED_DEFAULTS);
            let user_token = mySharedDefaults?.objectForKey("token") as! String
            
            let accounts = NSMutableArray()
            for index in 0 ..< selectedAccounts.count {
                let account = selectedAccounts[index] as! Account
                accounts.addObject(account.object_id)
            }
            
            var params = ["user_token":user_token,
                "message":text,
                "date": NSNumber.init(double: scheduleDate.timeIntervalSince1970*1000),
                "account_ids": accounts
            ]
            
            print("send params \(params)")
            
            if image != nil { // UPLOAD IMAGE AND POST
                
                let scale1 = 1024 / (image?.size.width)!
                let scale2 = 1024 / (image?.size.height)!
                
                let resized = image?.resize(min(scale1,scale2))
                
                let imageData = UIImagePNGRepresentation(resized!)
                let base64String = imageData!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
                
                params["media"] = base64String // "data:image/jpeg;base64," +
            }
            
            var URL = SERVER_BASE_URL+"/api/add_task"
            if scheduleDate.isLessThanDate(NSDate().addMinutes(1)) == true {
               URL = SERVER_BASE_URL+"/api/post_task"
                print("will post")
            } else {
                print("will schedule")
            }
            
            print("server url \(URL)")
            Alamofire.request(.POST, URL, parameters: params, encoding: .JSON).progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                print(totalBytesRead)
                dispatch_async(dispatch_get_main_queue()) {
                    print("Total bytes read on main queue: \(totalBytesRead)")
                }
                }.responseJSON { response in
                    print("got reposene \(response)")
                    if let error = response.result.error {
                        print("got error \(error)")
                        callback(false)
                        return
                    }
                    
                    callback(true)
            }

        }
    }
}

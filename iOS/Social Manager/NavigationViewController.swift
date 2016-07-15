//
//  NavigationViewController.swift
//  Social Manager
//
//  Created by Tomasz Baranowicz on 13/11/15.
//  Copyright © 2015 Direct Solutions. All rights reserved.
//

import UIKit
import Alamofire
import Google

class NavigationViewController: ENSideMenuNavigationController, ENSideMenuDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let viewController = storyboard.instantiateViewControllerWithIdentifier("sideMenuViewController") as! SideMenuViewController

        sideMenu = ENSideMenu(sourceView: self.view, menuViewController: viewController, menuPosition:.Left)
        //sideMenu?.delegate = self //optional
        sideMenu?.menuWidth = 200.0 // optional, default is 160
        sideMenu?.bouncingEnabled = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NavigationViewController.signOutNotificationHandler(_:)), name:NOTIFICATION_SIGN_OUT, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NavigationViewController.methodOfReceivedNotification(_:)), name:NOTIFICATION_ADD_ACCOUNT, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NavigationViewController.hideSideMenu), name:NOTIFICATION_ACCOUNT_SWITCHED, object: nil);
        
        // make navigation bar showing over side menu
        view.bringSubviewToFront(navigationBar)
    }
    
    func hideSideMenu() {
        sideMenu?.hideSideMenu()
    }
    
    func showLoginScreen() {
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("loginViewController") as! LoginViewController
        self.presentViewController(viewController, animated: true, completion: { () -> Void in})
    }
    
    func signOutNotificationHandler(notification: NSNotification){
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.objectForKey(TOKEN_KEY) != nil) {
            defaults.removeObjectForKey(TOKEN_KEY)
            defaults.synchronize()
            
            //remove everything from data manager
            DataManager.clearData()
            
            sideMenu?.hideSideMenu()
            showLoginScreen()
        }
    }
    
    func methodOfReceivedNotification(notification: NSNotification){
//        WORKING OAUTH
        let oauthswift = OAuth1Swift(
            consumerKey:    Twitter["consumerKey"]!,
            consumerSecret: Twitter["consumerSecret"]!,
            requestTokenUrl: "https://api.twitter.com/oauth/request_token",
            authorizeUrl:    "https://api.twitter.com/oauth/authorize",
            accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
        )
        
        let builder = GAIDictionaryBuilder.createEventWithCategory("add_account_action", action: "called", label: "", value: 1)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.send(builder.build() as [NSObject : AnyObject])
        
//        oauthswift.authorize_url_handler = WebViewController()
        let oauthVC = WebViewController()
        oauthVC.ownerViewController = self
        oauthswift.authorize_url_handler = oauthVC
        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/twitter")!, success: {
            credential, response in
            self.dismissViewControllerAnimated(true) { () -> Void in }
            let parameters =  Dictionary<String, AnyObject>()
            oauthswift.client.get("https://api.twitter.com/1.1/account/settings.json", parameters: parameters,
                success: {
                    data, response in
                    let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
                    print(jsonDict)
                    print("new twitter account \(jsonDict.objectForKey("screen_name")) \ntoken:\(credential.oauth_token)\n\noauth_toke_secret:\(credential.oauth_token_secret)")
                    
                    let defaults = NSUserDefaults.standardUserDefaults()
                    let user_token = defaults.stringForKey(TOKEN_KEY)! as String
                    
                    let builder = GAIDictionaryBuilder.createEventWithCategory("add_account_action", action: "success", label: "", value: 1)
                    let tracker = GAI.sharedInstance().defaultTracker
                    tracker.send(builder.build() as [NSObject : AnyObject])
                    
                    let params = ["secret": credential.oauth_token_secret, TOKEN_KEY: credential.oauth_token, "user_token": user_token]
                    print("send params \(params)")
                    Alamofire.request(.POST, SERVER_BASE_URL+"/api/add_account_twitter", parameters: params, encoding: .JSON)
                        .responseJSON { response in

                            if let JSON = response.result.value {
                                print("JSON: \(JSON)")
                            }
                            DataManager.refreshAccounts({ (array) -> Void in})
                    }

                }, failure: {(error:NSError!) -> Void in
                    let builder = GAIDictionaryBuilder.createEventWithCategory("add_account_action", action: "failure", label: error.localizedDescription, value: 2)
                    let tracker = GAI.sharedInstance().defaultTracker
                    tracker.send(builder.build() as [NSObject : AnyObject])
                    print(error.localizedDescription)
            })
            }, failure: {(error:NSError!) -> Void in
                let builder = GAIDictionaryBuilder.createEventWithCategory("add_account_action", action: "failure", label: error.localizedDescription, value: 1)
                let tracker = GAI.sharedInstance().defaultTracker
                tracker.send(builder.build() as [NSObject : AnyObject])
                print(error.localizedDescription)
            }
        )
    }

    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
        print("sideMenuWillOpen")
    }
    
    func sideMenuWillClose() {
        print("sideMenuWillClose")
    }
    
    func sideMenuDidClose() {
        print("sideMenuDidClose")
    }
    
    func sideMenuDidOpen() {
        print("sideMenuDidOpen")
    }
}

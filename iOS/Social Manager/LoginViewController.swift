//
//  LoginViewController.swift
//  Social Manager
//
//  Created by Tomasz Baranowicz on 13/11/15.
//  Copyright © 2015 Direct Solutions. All rights reserved.
//

import UIKit
import Alamofire
import Google

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton?
    let tracker = GAI.sharedInstance().defaultTracker
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tracker.set(kGAIScreenName, value: "Login Screen")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    @IBAction func twitterLoginAction(sender: UIButton) {

        //WORKING OAUTH
        let oauthswift = OAuth1Swift(
            consumerKey:    Twitter["consumerKey"]!,
            consumerSecret: Twitter["consumerSecret"]!,
            requestTokenUrl: "https://api.twitter.com/oauth/request_token",
            authorizeUrl:    "https://api.twitter.com/oauth/authorize",
            accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
        )
        let oauthVC = WebViewController()
        oauthVC.ownerViewController = self
        oauthswift.authorize_url_handler = oauthVC
        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/twitter")!, success: {
            credential, response in
            print("token:\(credential.oauth_token)\n\noauth_toke_secret:\(credential.oauth_token_secret)")
            self.dismissViewControllerAnimated(true) { () -> Void in }
            PKHUD.sharedHUD.contentView = PKHUDProgressView()
            PKHUD.sharedHUD.show()
            
            let params = ["secret": credential.oauth_token_secret, TOKEN_KEY: credential.oauth_token]
            print("send params \(params)")
            Alamofire.request(.POST, SERVER_BASE_URL+"/api/login_twitter", parameters: params, encoding: .JSON)
                .responseJSON { response in
                    
                    PKHUD.sharedHUD.contentView = PKHUDSuccessView()
                    PKHUD.sharedHUD.hide(afterDelay: 0.0)
                    
                    guard let JSON = response.result.value
                        else {
                            self.showAlertView("Problem", message: "Server cannot authenticate you, please try again, sorry about that :)")
                            return
                        }
                    
                    
                    let token = JSON.valueForKey(TOKEN_KEY)
                    
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(token, forKey: TOKEN_KEY)
                    defaults.synchronize()
                    
                    let builder = GAIDictionaryBuilder.createEventWithCategory("login_action", action: "success", label: "", value: 1)
                    self.tracker.send(builder.build() as [NSObject : AnyObject])
                    
                    self.dismissViewControllerAnimated(true) { () -> Void in }
                }
            }, failure: {(error:NSError!) -> Void in
                let builder = GAIDictionaryBuilder.createEventWithCategory("login_action", action: "failure", label: "", value: 1)
                self.tracker.send(builder.build() as [NSObject : AnyObject])
                
                print(error.localizedDescription)
            }
        )
    }
    
    func showAlertView(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

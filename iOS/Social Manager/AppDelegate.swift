//
//  AppDelegate.swift
//  Social Manager
//
//  Created by Tomasz Baranowicz on 13/11/15.
//  Copyright © 2015 Direct Solutions. All rights reserved.
//

import UIKit
import Google

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var shortcutItem: UIApplicationShortcutItem?
    var openCreator = false

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        // Optional: configure GAI options.
        let gai = GAI.sharedInstance()
        gai.trackUncaughtExceptions = true  // report uncaught exceptions
        gai.logger.logLevel = GAILogLevel.Verbose  // remove before app release
        
        var performShortcutDelegate = true
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
            
            print("Application launched via shortcut")
            self.shortcutItem = shortcutItem
   
            performShortcutDelegate = false
        }
        return performShortcutDelegate
    }

    func handleShortcut( shortcutItem:UIApplicationShortcutItem ) -> Bool {
        print("Handling shortcut")
        
        var succeeded = false
        openCreator = false
        if( shortcutItem.type == "net.postmanager.ios.new-post" ) {
            openCreator = true
            // Add your code here
            print("- Handling \(shortcutItem.type)")
            NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_QUICK_ACTION_COMPOSE, object: nil)
            succeeded = true
        }
        
        return succeeded
    }
    
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        
        print("Application performActionForShortcutItem")
        completionHandler( handleShortcut(shortcutItem) )
        
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        print("Application did become active")
        guard let shortcut = shortcutItem else { return }
        
        print("- Shortcut property has been set")
        
        handleShortcut(shortcut)
        
        self.shortcutItem = nil
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if (url.host == "oauth-callback") {
            if (url.path!.hasPrefix("/twitter") || url.path!.hasPrefix("/flickr") || url.path!.hasPrefix("/fitbit")
                || url.path!.hasPrefix("/withings") || url.path!.hasPrefix("/linkedin") || url.path!.hasPrefix("/bitbucket") || url.path!.hasPrefix("/smugmug") || url.path!.hasPrefix("/intuit") || url.path!.hasPrefix("/zaim") || url.path!.hasPrefix("/tumblr")) {
                    OAuth1Swift.handleOpenURL(url)
            }
            if ( url.path!.hasPrefix("/github" ) || url.path!.hasPrefix("/instagram" ) || url.path!.hasPrefix("/foursquare") || url.path!.hasPrefix("/dropbox") || url.path!.hasPrefix("/dribbble") || url.path!.hasPrefix("/salesforce") || url.path!.hasPrefix("/google") || url.path!.hasPrefix("/linkedin2") || url.path!.hasPrefix("/slack") || url.path!.hasPrefix("/uber")) {
                OAuth2Swift.handleOpenURL(url)
            }
        } else {
            // Google provider is the only one wuth your.bundle.id url schema.
            OAuth2Swift.handleOpenURL(url)
        }
        return true
    }
}


//
//  OAuthWebViewController.swift
//  OAuthSwift
//
//  Created by Dongri Jin on 2/11/15.
//  Copyright (c) 2015 Dongri Jin. All rights reserved.
//

import Foundation

#if os(iOS)
    import UIKit
    public typealias OAuthViewController = UIViewController
#elseif os(OSX)
    import AppKit
    public typealias OAuthViewController = NSViewController
#endif

public class OAuthWebViewController: OAuthViewController, OAuthSwiftURLHandlerType {

    var ownerViewController : UIViewController?
//    let webView : UIWebView = UIWebView()
    
//    public init(viewController : UIViewController) {
//        super.init(nibName: nil, bundle: nil)
//        self.ownerViewController = viewController
//    }
//
//    required public init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    public func handle(url: NSURL){
        #if os(iOS)
            #if !OAUTH_APP_EXTENSIONS
                
//                UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(
//                    self, animated: true, completion: nil)
//                
//                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                let initViewController: UIViewController = storyBoard.instantiateViewControllerWithIdentifier("loginViewController")
//                print("will try to show on \(initViewController.classForCoder)")
                self.ownerViewController?.presentViewController(self, animated: true, completion: nil)

            #endif
        #elseif os(OSX)
            if let p = self.parentViewController { // default behaviour if this controller affected as child controller
                p.presentViewControllerAsModalWindow(self)
            } else if let window = self.view.window {
                window.makeKeyAndOrderFront(nil)
            }
            // or create an NSWindow or NSWindowController (/!\ keep a strong reference on it)
        #endif
    }

    public func dismissWebViewController() {
        #if os(iOS)
            self.dismissViewControllerAnimated(true, completion: nil)
        #elseif os(OSX)
            if self.presentingViewController != nil { // if presentViewControllerAsModalWindow
                self.dismissController(nil)
                if self.parentViewController != nil {
                    self.removeFromParentViewController()
                }
            }
            else if let window = self.view.window {
                window.performClose(nil)
            }
        #endif
    }
}
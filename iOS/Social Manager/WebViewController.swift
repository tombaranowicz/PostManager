//
//  WebViewController.swift
//  Social Manager
//
//  Created by Tomasz Baranowicz on 08/02/16.
//  Copyright © 2016 Direct Solutions. All rights reserved.
//

import UIKit

class WebViewController: OAuthWebViewController {
    
    var targetURL : NSURL = NSURL()
    let webView : UIWebView = UIWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.frame = UIScreen.mainScreen().bounds
        // self.webView.delegate = self
        self.view.addSubview(self.webView)
        loadAddressURL()
        
        let leftBarButton = UIBarButtonItem(title: "", style: .Plain, target: self, action: "closeAction")
        let attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(20)] as Dictionary!
        leftBarButton.setTitleTextAttributes(attributes, forState: .Normal)
        leftBarButton.title = String.fontAwesomeIconWithName(FontAwesome.Times)
        self.navigationItem.leftBarButtonItem = leftBarButton;
        
        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.translucent = false;
    }
    
    func closeAction() {
        dismissViewControllerAnimated(true) { () -> Void in}
    }
    
    override func handle(url: NSURL) {
        targetURL = url
//        super.handle(url)
        
        let nav = WebNavigationViewController(rootViewController: self)
        self.ownerViewController?.presentViewController(nav, animated: true, completion: nil)
        
        loadAddressURL()
    }
    
    func loadAddressURL() {
        let req = NSURLRequest(URL: targetURL)
        self.webView.loadRequest(req)
    }
}
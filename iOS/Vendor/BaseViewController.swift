//
//  BaseViewController.swift
//  Social Manager
//
//  Created by Tomasz Baranowicz on 13/11/15.
//  Copyright © 2015 Direct Solutions. All rights reserved.
//

import UIKit
import Google

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let leftBarButton = UIBarButtonItem(title: "", style: .Plain, target: self, action: #selector(BaseViewController.toggleMenu))
        var attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(20)] as Dictionary!
        leftBarButton.setTitleTextAttributes(attributes, forState: .Normal)
        leftBarButton.title = String.fontAwesomeIconWithName(FontAwesome.Bars)
        leftBarButton.tintColor = BLACK_TEXT_COLOR
        self.navigationItem.leftBarButtonItem = leftBarButton;
        
        let rightBarButton = UIBarButtonItem(title: "", style: .Plain, target: self, action: #selector(BaseViewController.compose as (BaseViewController) -> () -> ()))
        attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(20)] as Dictionary!
        rightBarButton.setTitleTextAttributes(attributes, forState: .Normal)
        rightBarButton.title = String.fontAwesomeIconWithName(FontAwesome.Pencil)
        rightBarButton.tintColor = BLACK_TEXT_COLOR
        self.navigationItem.rightBarButtonItem = rightBarButton;
    }
    
    func logScreen(screenName : String) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: screenName)
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }

    func toggleMenu() {
        toggleSideMenuView()
    }
    
    func compose() {
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("composeViewController") as! ComposeViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.navigationBar.tintColor = BLACK_TEXT_COLOR
        navController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : BLACK_TEXT_COLOR]
        self.navigationController?.presentViewController(navController, animated: true, completion: { () -> Void in})
    }
    
    func compose(image: UIImage?, text: String) {
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("composeViewController") as! ComposeViewController
        viewController.presetText = text
        if image != nil {
            viewController.preselectedImage = image
        }
        let navController = UINavigationController(rootViewController: viewController)
        navController.navigationBar.tintColor = BLACK_TEXT_COLOR
        navController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : BLACK_TEXT_COLOR]
        self.navigationController?.presentViewController(navController, animated: true, completion: { () -> Void in})
    }
}

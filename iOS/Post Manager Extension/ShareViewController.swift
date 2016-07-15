//
//  ShareViewController.swift
//  Post Manager Extension
//
//  Created by Tomasz Baranowicz on 13/02/16.
//  Copyright © 2016 Direct Solutions. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {

    var selectedImage: UIImage?
    var selectedURL: String?
    
    //accounts
    var accountsItem: SLComposeSheetConfigurationItem!
    var accountPickerVC: AccountsTableViewController!
    let accounts : NSMutableArray = NSMutableArray()
    let selectedAccounts : NSMutableArray = NSMutableArray()
    
    //date
    var scheduleItem: SLComposeSheetConfigurationItem!
    var schedulePickerVC: ScheduleViewController!
    var selectedDate = NSDate()
    
    //token
    var token: String?
    
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        if let img = UIImage(named: "icon.png") {
            img.drawInRect(CGRectMake((size.width-size.height)/2, 0, size.height, size.height))
        }
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        let navSize = self.navigationController?.navigationBar.frame.size
        self.navigationController?.navigationBar.setBackgroundImage(getImageWithColor(UIColor.whiteColor(), size: navSize!), forBarMetrics: .Default)

        let mySharedDefaults = NSUserDefaults(suiteName: SHARED_DEFAULTS);
        let data = mySharedDefaults?.objectForKey("accounts")
        let array = NSKeyedUnarchiver.unarchiveObjectWithData(data as! NSData) as! NSArray
        token = mySharedDefaults?.objectForKey("token") as? String
        
        for dict in array {
            let account = Account(dictionary: dict as! NSDictionary)
            accounts.addObject(account)
            selectedAccounts.addObject(account)
        }
        
        let content = self.extensionContext!.inputItems[0] as! NSExtensionItem
        let contentTypeImage = kUTTypeImage as String
        let contentTypeURL = kUTTypeURL as String
        
        for attachment in content.attachments as! [NSItemProvider] {
            print("attachment \(attachment.registeredTypeIdentifiers)")
            
            if attachment.hasItemConformingToTypeIdentifier(contentTypeImage) {
                
                attachment.loadItemForTypeIdentifier(contentTypeImage, options: nil) { data, error in
                    if error == nil {
                        let url = data as! NSURL
                        if let imageData = NSData(contentsOfURL: url) {
                            self.selectedImage = UIImage(data: imageData)
                            print("found image \(self.selectedImage?.size)")
                        }
                    }
                }
            } else if attachment.hasItemConformingToTypeIdentifier(contentTypeURL) {
                
                attachment.loadItemForTypeIdentifier(contentTypeURL, options: nil) { data, error in
                    if error == nil {
                        let url = data as! NSURL
                        self.selectedURL = url.absoluteString
                        print("found url \(self.selectedURL)")
                    }
                }
            }
        }
    }

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        if self.selectedAccounts.count == 0 {
           return
        }
        
        if self.token == nil {
            let alert = UIAlertController(title: "Problem", message: "Please login using the app in order to use extension.", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                
            }
            alert.addAction(OKAction)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {

            var message = self.textView.text
            if self.selectedURL != nil {
                message = self.textView.text + " \(self.selectedURL!)"
            }
            
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                DataManager.schedulePost(self.selectedAccounts, text: message, image: self.selectedImage, scheduleDate: self.selectedDate, callback: { (success: Bool) -> Void in })
            }
            
            self.extensionContext!.completeRequestReturningItems([], completionHandler: nil)
        }
    }
    
    override func configurationItems() -> [AnyObject]! {

        self.accountsItem = SLComposeSheetConfigurationItem()
        self.accountsItem.title = "Selected accounts"
        self.accountsItem.value = "\(selectedAccounts.count)"
        self.accountsItem.tapHandler = {
            self.accountPickerVC = AccountsTableViewController()
            self.accountPickerVC.accounts = self.accounts
            self.accountPickerVC.selectedAccounts = self.selectedAccounts
            self.accountPickerVC.accountsSelector = self
            self.pushConfigurationViewController(self.accountPickerVC)
        }
        
        self.scheduleItem = SLComposeSheetConfigurationItem()
        self.scheduleItem.title = "Schedule"
        self.scheduleItem.value = "Send Now"
        self.scheduleItem.tapHandler = {
            self.schedulePickerVC = ScheduleViewController()
            self.schedulePickerVC.selectedDate = self.selectedDate
            self.schedulePickerVC.dateSelector = self
            self.pushConfigurationViewController(self.schedulePickerVC)
        }
        
        return [self.accountsItem, self.scheduleItem]
    }
}

extension ShareViewController : AccountsSelector {
    func selectorSelectedAccounts() {
        self.accountsItem.value = "\(self.selectedAccounts.count)"
    }
}

extension ShareViewController : DateSelector {
    func selectorSelectedDate(date: NSDate) {
        self.selectedDate = date
        
        let now = NSDate()
        now.addMinutes(1)
        
        if self.selectedDate.isLessThanDate(now) == true {
            self.scheduleItem.value = "Send Now"
        } else {
            let formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.MediumStyle
            formatter.timeStyle = .ShortStyle
            self.scheduleItem.value = "\(formatter.stringFromDate(self.selectedDate))"
        }
    }
}

//NSExtensionActivationSupportsAttachmentsWithMaxCount
//NSExtensionActivationSupportsAttachmentsWithMinCount
//NSExtensionActivationSupportsFileWithMaxCount
//NSExtensionActivationSupportsImageWithMaxCount
//NSExtensionActivationSupportsMovieWithMaxCount
//NSExtensionActivationSupportsText
//NSExtensionActivationSupportsWebURLWithMaxCount
//NSExtensionActivationSupportsWebPageWithMaxCount
//
//  ComposeViewController.swift
//  Social Manager
//
//  Created by Tomasz Baranowicz on 14/11/15.
//  Copyright © 2015 Direct Solutions. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import Google

class ComposeViewController: UIViewController, UINavigationControllerDelegate {

    let PLACEHOLDER = "What would you like to share?"
    @IBOutlet weak var accountsScrollView: UIScrollView?
    @IBOutlet weak var inputTextView: UITextView?
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint?
    @IBOutlet weak var attachImageView: UIImageView?
    @IBOutlet weak var scheduleButton: UIButton?
    @IBOutlet weak var attachButtonConstraint: NSLayoutConstraint?
    @IBOutlet weak var counterLabel: UILabel?
    
    let accounts : NSMutableArray = NSMutableArray()
    let accountViews : NSMutableArray = NSMutableArray()
    let imagePicker = UIImagePickerController()
    var image : UIImage?
    var scheduleDate : NSDate?
    let textLimit = 140
    
    var postCounter = 0
    let tracker = GAI.sharedInstance().defaultTracker
    
    var preselectedImage : UIImage?
    var presetText : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "New Post"
        
        let leftBarButton = UIBarButtonItem(title: "", style: .Plain, target: self, action: #selector(ComposeViewController.closeAction))
        var attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(20)] as Dictionary!
        leftBarButton.setTitleTextAttributes(attributes, forState: .Normal)
        leftBarButton.title = String.fontAwesomeIconWithName(FontAwesome.Times)
        self.navigationItem.leftBarButtonItem = leftBarButton;
        
        let rightBarButton = UIBarButtonItem(title: "", style: .Plain, target: self, action: #selector(ComposeViewController.sendAction))
        attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(16)] as Dictionary!
        rightBarButton.setTitleTextAttributes(attributes, forState: .Normal)
        rightBarButton.title = String.fontAwesomeIconWithName(FontAwesome.Send)
        self.navigationItem.rightBarButtonItem = rightBarButton;
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ComposeViewController.photoAction))
        self.attachImageView!.addGestureRecognizer(tap)
        
        self.inputTextView?.text = PLACEHOLDER
        self.inputTextView?.textColor = UIColor.lightGrayColor()
        self.inputTextView?.selectedTextRange = self.inputTextView?.textRangeFromPosition(self.inputTextView!.beginningOfDocument, toPosition: self.inputTextView!.beginningOfDocument)
        
        counterLabel?.text = "0/\(textLimit)"
        imagePicker.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ComposeViewController.reloadAccounts), name:NOTIFICATION_ACCOUNTS_REFRESHED, object: nil);
        reloadAccounts()
        
        tracker.set(kGAIScreenName, value: "Compose Screen")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ComposeViewController.keyboardWillShowNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ComposeViewController.keyboardWillHideNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        inputTextView?.becomeFirstResponder()
        
        if self.preselectedImage != nil {
            self.image = self.preselectedImage
            attachImageView?.image = self.image;
            self.attachButtonConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
        
        if self.presetText != nil {
            self.inputTextView?.text = self.presetText
            self.inputTextView?.textColor = UIColor.blackColor()
            counterLabel?.text = "\(self.presetText!.characters.count)/\(textLimit)"
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func reloadAccounts() {
        self.accounts.removeAllObjects()
        for index in 0 ..< accountViews.count {
            let accountView = accountViews[index] as! ComposeAccountView
            accountView.removeFromSuperview()
        }

        self.accounts.addObjectsFromArray(DataManager.accounts as [AnyObject])
        for index in 0 ..< accounts.count {
            let account = accounts[index]
            let accountView = ComposeAccountView(frame:CGRectMake(CGFloat(index*50), 0, 50, 50), account:account as! Account)
            accountsScrollView?.addSubview(accountView)
            accountViews.addObject(accountView)
        }
        
        accountsScrollView?.contentSize = CGSizeMake(CGFloat(accounts.count*50), 50)
    }
    
    func completeHandler() {
        dispatch_async(dispatch_get_main_queue()) {
            self.postCounter -= 1
            if self.postCounter == 0 {
                PKHUD.sharedHUD.hide()
                self.showSuccessAlert(false)
            }
        }
    }
    
    func sendAction() {
        let selectedAccounts = NSMutableArray()
        
        for index in 0 ..< accountViews.count {
            let accountView = accountViews[index] as! ComposeAccountView
            if accountView.selected {
                selectedAccounts.addObject(accountView.account)
            }
        }
        
        if selectedAccounts.count == 0 {
            let alertController = UIAlertController(title: "Error", message: "Please select at least one account.", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alertController, animated: true, completion: nil)
        } else if inputTextView!.text.length() == 0 {
            let alertController = UIAlertController(title: "Error", message: "Please write some text to be shared.", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            
            PKHUD.sharedHUD.contentView = PKHUDProgressView()
            PKHUD.sharedHUD.show()
            
            var date = scheduleDate

            let now = NSDate()
            now.addMinutes(1)
            
            if date != nil && !date!.isLessThanDate(now) {
                let builder = GAIDictionaryBuilder.createEventWithCategory("compose_action", action: "send_schedule", label: "", value: selectedAccounts.count)
                tracker.send(builder.build() as [NSObject : AnyObject])
            } else {
                let builder = GAIDictionaryBuilder.createEventWithCategory("compose_action", action: "send_direct", label: "", value: selectedAccounts.count)
                tracker.send(builder.build() as [NSObject : AnyObject])
                date = NSDate()
            }
            
            DataManager.schedulePost(selectedAccounts, text: self.inputTextView!.text, image: self.image, scheduleDate: date!, callback: { (success: Bool) -> Void in
                if (success) {
                    PKHUD.sharedHUD.hide()
                    self.showSuccessAlert(date != nil && !date!.isLessThanDate(now))
                } else {
                    PKHUD.sharedHUD.hide()
                    self.showFailureAlert()
                }
            })
        }
    }

    func showSuccessAlert(scheduled: Bool) {
        
        var message : String = "Tweet was posted."
        if scheduled {
            message = "Tweet is now scheduled."
        }
        
        let alertController = UIAlertController(title: "Success", message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Continue", style: .Default, handler: { (action) -> Void in
            self.clear()
        }))
        alertController.addAction(UIAlertAction(title: "Close", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true) { () -> Void in}
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showFailureAlert() {
        
        let alertController = UIAlertController(title: "Failure", message: "Tweet was not posted.", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Try Again", style: .Default, handler: { (action) -> Void in
            self.sendAction()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in
            
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func clear() {
        image = nil;
        attachImageView?.image = nil;
        inputTextView?.text = ""
        
        self.attachButtonConstraint?.constant = 90
        self.view.layoutIfNeeded()
    }
    
    func photoAction() {
        if self.image != nil {
            let alert = UIAlertController(title: "Attachment", message: "Choose action.", preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            let libButton = UIAlertAction(title: "Remove Attachment", style: UIAlertActionStyle.Destructive) { (alert) -> Void in
                self.image = nil;
                self.attachImageView?.image = nil;
                self.attachButtonConstraint?.constant = 90
                self.view.layoutIfNeeded()
            }
            alert.addAction(libButton)
            
            let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert) -> Void in}
            
            alert.addAction(cancelButton)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func scheduleAction(sender: UIButton) {
        DatePickerDialog().show("Choose post date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .DateAndTime) {
            (date) -> Void in
            print("\(date)")
            self.scheduleDate = date

            let formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.MediumStyle
            formatter.timeStyle = .ShortStyle
            self.scheduleButton?.setTitle("\(formatter.stringFromDate(date))", forState: UIControlState.Normal)
        }
    }
    
    func closeAction() {
        dismissViewControllerAnimated(true) { () -> Void in}
    }
    
    @IBAction func attachPhotoAction(sender: UIButton) {
        let alert = UIAlertController(title: "Attach Photo", message: "Currently you can attach only one photo to your post.", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let libButton = UIAlertAction(title: "Select photo from library", style: UIAlertActionStyle.Default) { (alert) -> Void in
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        alert.addAction(libButton)
        
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            let cameraButton = UIAlertAction(title: "Take a picture", style: UIAlertActionStyle.Default) { (alert) -> Void in
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
            alert.addAction(cameraButton)
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert) -> Void in

        }

        alert.addAction(cancelButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Notifications
    func keyboardWillShowNotification(notification: NSNotification) {
        updateBottomLayoutConstraintWithNotification(notification)
    }
    
    func keyboardWillHideNotification(notification: NSNotification) {
        updateBottomLayoutConstraintWithNotification(notification)
    }
    
    // MARK: - Private
    func updateBottomLayoutConstraintWithNotification(notification: NSNotification) {
        let userInfo = notification.userInfo!
        
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let convertedKeyboardEndFrame = view.convertRect(keyboardEndFrame, fromView: view.window)
        bottomConstraint!.constant = CGRectGetMaxY(view.bounds) - CGRectGetMinY(convertedKeyboardEndFrame)
        
        UIView.animateWithDuration(animationDuration, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

extension ComposeViewController : UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.image = image;
        attachImageView?.image = image;
        self.attachButtonConstraint?.constant = 0
        self.view.layoutIfNeeded()
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ComposeViewController : UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText : NSString = textView.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
        
        if updatedText.length()>textLimit {
            textView.text = updatedText.substringToIndex(updatedText.startIndex.advancedBy(textLimit))
            counterLabel?.text = "\(textView.text.length())/\(textLimit)"
            return false
        }
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty || updatedText == PLACEHOLDER {
            textView.text = PLACEHOLDER
            textView.textColor = UIColor.lightGrayColor()
            textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            counterLabel?.text = "0/\(textLimit)"
            return false
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, clear
            // the text view and set its color to black to prepare for
            // the user's entry
        else if textView.textColor == UIColor.lightGrayColor() {//&& !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
            counterLabel?.text = "\(text.length())/\(textLimit)"
        }
            
        else {
            counterLabel?.text = "\(updatedText.length())/\(textLimit)"
        }
        
        return true
    }

    //   func textViewDidChange(textView: UITextView) {
    //     print("textview did change \(textView.text)")
    //
    //let string = textView.text
    // let types: NSTextCheckingType = [NSTextCheckingType.Link]
    //    let detector = try? NSDataDetector(types: types.rawValue)
    //    detector?.enumerateMatchesInString(string, options: [], range: NSMakeRange(0, (string as NSString).length)) { (result, flags, _) in
    //        print(result?.URL)
    //    }
    // }
}



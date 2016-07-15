//
//  ComposeAccountView.swift
//  Social Manager
//
//  Created by Tomasz Baranowicz on 14/11/15.
//  Copyright © 2015 Direct Solutions. All rights reserved.
//

import UIKit

class ComposeAccountView: UIView {

    var selected = false
    var image : UIImageView?
    var account : Account!
    var label : UILabel?
    var locked : Bool?
    
    override init (frame : CGRect) {
        super.init(frame : frame)
    }
    
    convenience init(frame: CGRect, account: Account) {
        self.init(frame: frame)
        
        self.account = account
        self.image = UIImageView(frame: CGRectMake(5, 5, frame.width-10, frame.height-10))
        self.image?.layer.cornerRadius = self.image!.frame.width / 2
        self.image?.clipsToBounds = true
        self.addSubview(self.image!)
        
        self.label = UILabel(frame: CGRectMake(frame.width-20, frame.height-20, 18, 18))
        self.label?.font = UIFont.fontAwesomeOfSize(12)
        self.label?.text = String.fontAwesomeIconWithName(FontAwesome.Twitter)
        self.label?.textColor = UIColor.whiteColor()
        self.label?.textAlignment = NSTextAlignment.Center
        self.label?.backgroundColor = UIColor.lightGrayColor()
        self.label?.layer.cornerRadius = 9
        self.label?.layer.masksToBounds = true

        self.addSubview(self.label!)
        
        downloadImage(NSURL(string: self.account.profile_image_url!)!)
        
        self.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(ComposeAccountView.tapHandler))
        self.addGestureRecognizer(tap)
        
        if account.object_id == DataManager.activeAccount?.object_id {
            self.tapHandler()
        }
    }
    
    func tapHandler() {
        if (locked != nil && locked == true) {
            return
        }
        self.selected = !self.selected
        if selected {
            self.label?.backgroundColor = TWITTER_COLOR
        } else {
            self.label?.backgroundColor = UIColor.lightGrayColor()
        }
    }
    
    func downloadImage(url: NSURL){
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                self.image!.image = UIImage(data: data)
            }
        }
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

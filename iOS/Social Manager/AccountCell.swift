//
//  AccountCell.swift
//  Social Manager
//
//  Created by Tomasz Baranowicz on 09/01/16.
//  Copyright © 2016 Direct Solutions. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

protocol AccountCellDelegate {
    func switchedCell(cell: AccountCell)
}

class AccountCell: UITableViewCell {
    
    var taskTextLabel : UILabel?
    var taskImageView : UIImageView?
    let margin : CGFloat = 10.0
    let width : CGFloat = 200.0
    let height : CGFloat = 60.0
    var label : UILabel?
    var activeLabel : UILabel?
    var delegate: AccountCellDelegate?
    var acc: Account?
    
    //used only in extension
    var selectSwitch : UISwitch?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        taskImageView = UIImageView(frame: CGRectMake(margin, margin, height-2*margin, height-2*margin))
        taskImageView?.layer.cornerRadius = (height-2*margin)/2
        taskImageView?.layer.masksToBounds = true
        taskImageView?.clipsToBounds = true
        taskImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        self.contentView.addSubview(taskImageView!)
        
        self.label = UILabel(frame: CGRectMake(height-25, height-25, 20, 20))
        self.label?.font = UIFont.fontAwesomeOfSize(12)
        self.label?.text = String.fontAwesomeIconWithName(FontAwesome.Twitter)
        self.label?.textColor = UIColor.whiteColor()
        self.label?.textAlignment = NSTextAlignment.Center
        self.label?.backgroundColor = TWITTER_COLOR
        self.label?.layer.cornerRadius = 10
        self.label?.layer.masksToBounds = true
        self.contentView.addSubview(self.label!)
        
        self.taskTextLabel = UILabel(frame: CGRectMake(taskImageView!.frame.size.width + 2*margin, margin, width-taskImageView!.frame.size.width - 3*margin, height-2*margin))
        self.taskTextLabel?.font = UIFont.boldSystemFontOfSize(14)
        self.taskTextLabel!.textColor = BLACK_TEXT_COLOR
        self.contentView.addSubview(taskTextLabel!)
        
        self.activeLabel = UILabel(frame: CGRectMake(width-2*margin, height-2*margin, 15, 15))
        self.activeLabel?.font = UIFont.fontAwesomeOfSize(15)
        self.activeLabel?.text = String.fontAwesomeIconWithName(FontAwesome.CheckCircle)
        self.activeLabel!.textColor = BLACK_TEXT_COLOR
        self.contentView.addSubview(activeLabel!)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSwitch (selected: Bool, tag: Int) {
        if selectSwitch == nil {
            self.selectSwitch = UISwitch()
            self.selectSwitch?.tag = tag
            self.accessoryView = self.selectSwitch
        }
        self.selectSwitch?.setOn(selected, animated: true)
        self.selectSwitch?.addTarget(self, action: #selector(AccountCell.doToggle(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.activeLabel?.hidden = true
    }
    
    func doToggle(switch: UISwitch) {
        if let delegate = self.delegate {
            delegate.switchedCell(self)
        }
    }
    
    func setAccount(account: Account) {
        
        self.acc = account
        if let imagePath = account.profile_image_url {
            print("image \(imagePath)")
            Alamofire.request(.GET, imagePath).responseImage { response in
                if let image = response.result.value {
                    self.taskImageView?.image = image
                }
            }
        }
        self.taskTextLabel?.text = account.login
        self.activeLabel?.alpha = 0.0
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        if selected {
            self.activeLabel?.alpha = 1.0
        } else {
            self.activeLabel?.alpha = 0.0
        }
    }
}
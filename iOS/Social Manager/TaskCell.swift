//
//  TaskCell.swift
//  Social Manager
//
//  Created by Tomasz Baranowicz on 07/01/16.
//  Copyright © 2016 Direct Solutions. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class TaskCell: UITableViewCell {
    
    var taskTextLabel : UILabel?
    var dateLabel : UILabel?
    var taskImageView : UIImageView?
    let margin : CGFloat = 10.0
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var cardBackgroundView : UIView?
    var accountsScrollView : UIScrollView?
    var accountViews = NSMutableArray()
    
    let formatter = NSDateFormatter()
    
    func applyPlainShadow(view: UIView) {
        let layer = view.layer
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 0.4
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        formatter.timeStyle = .ShortStyle
        
        self.contentView.backgroundColor = UIColor.init(white: 0.92, alpha: 1)
        
        self.cardBackgroundView = UIView(frame: CGRectMake(margin/2, margin/2, self.frame.size.width-margin, 100))
        self.cardBackgroundView!.backgroundColor = UIColor.whiteColor()
        
        self.contentView.addSubview(self.cardBackgroundView!)
        
        taskImageView = UIImageView(frame: CGRectMake(margin, margin, self.frame.size.width-2*margin, screenSize.size.width/2))
        taskImageView?.clipsToBounds = true
        taskImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        self.contentView.addSubview(taskImageView!)
        
        self.taskTextLabel = UILabel(frame: CGRectMake(margin, CGRectGetMaxY(taskImageView!.frame)+margin, self.frame.size.width-2*margin, 20))
        self.taskTextLabel!.numberOfLines = 0
        self.taskTextLabel?.font = UIFont(name: self.taskTextLabel!.font.fontName, size: 14)
        self.taskTextLabel!.textColor = BLACK_TEXT_COLOR
        self.contentView.addSubview(taskTextLabel!)
        
        self.dateLabel = UILabel(frame: CGRectMake(margin, CGRectGetMaxY(self.taskTextLabel!.frame)+margin, self.frame.size.width-2*margin, 13))
        self.dateLabel!.font = UIFont(name: self.dateLabel!.font.fontName, size: 12)
        self.dateLabel!.textColor = DARK_GRAY_TEXT_COLOR
        self.contentView.addSubview(dateLabel!)
        
        self.accountsScrollView = UIScrollView(frame: CGRectMake(margin, CGRectGetMaxY(self.dateLabel!.frame), self.frame.size.width-2*margin, 45))
        self.contentView.addSubview(accountsScrollView!)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTask(task: Task) {
        
        if let imagePath = task.media_path {
            taskImageView?.frame = CGRectMake(margin, margin, self.frame.size.width-2*margin, screenSize.size.width/2)
            self.taskTextLabel?.frame = CGRectMake(margin, CGRectGetMaxY(taskImageView!.frame)+margin, self.frame.size.width-2*margin, 20)
            print("image \(SERVER_BASE_URL+imagePath)")
            Alamofire.request(.GET, SERVER_BASE_URL+imagePath).responseImage { response in
//                    debugPrint(response)
//                    print(response.request)
//                    print(response.response)
                    debugPrint(response.result)
                
                    if let image = response.result.value {
                        print("image downloaded: \(image)")
                        self.taskImageView?.image = image
                    }
            }
            
        } else {
            taskImageView?.frame = CGRectMake(margin, margin, self.frame.size.width-2*margin, 0)
            self.taskTextLabel?.frame = CGRectMake(margin, margin, self.frame.size.width-2*margin, 20)
        }

        //text
        self.taskTextLabel?.text = task.message
        self.taskTextLabel?.sizeToFit()
        
        //date
        self.dateLabel?.frame = CGRectMake(margin, CGRectGetMaxY(self.taskTextLabel!.frame)+margin, self.frame.size.width-2*margin, 13)
        self.dateLabel?.text = "Scheduled for \(formatter.stringFromDate(task.date))."
        
        //accounts
        self.accountsScrollView?.frame = CGRectMake(margin, CGRectGetMaxY(self.dateLabel!.frame), self.frame.size.width-2*margin, 45)
        for view in self.accountViews  {
            view.removeFromSuperview()
        }
        self.accountViews.removeAllObjects()
        
        
        DataManager.accountsWithIds(task.accounts, callback: { (fullAccounts) -> Void in
            for index in 0 ..< fullAccounts.count {
                let account = fullAccounts[index]
                let accountView = ComposeAccountView(frame:CGRectMake(CGFloat(index*45), 0, 45, 45), account:account as! Account)
                accountView.tapHandler()
                accountView.locked = true
                self.accountsScrollView?.addSubview(accountView)
                self.accountViews.addObject(accountView)
            }
        })
        
        self.cardBackgroundView?.frame = CGRectMake(margin/2, margin/2, self.frame.size.width-margin, CGRectGetMaxY((self.accountsScrollView?.frame)!))
    }
    
    static func cellHeigh(task: Task) -> CGFloat {

        let margin : CGFloat = 10.0
        var height : CGFloat = margin
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        if task.media_path != nil {
            height += screenSize.size.width/2
            height += margin
        }
        
        let taskTextLabel = UILabel(frame: CGRectMake(margin, 0, screenSize.size.width-2*margin, 20))
        taskTextLabel.numberOfLines = 0
        taskTextLabel.font = UIFont(name:taskTextLabel.font.fontName, size: 14)
        taskTextLabel.text = task.message
        taskTextLabel.sizeToFit()
        
        height+=taskTextLabel.frame.size.height
        height+=margin
        
        height+=13
        
        height+=45
        height+=margin
        
        return height
    }

}

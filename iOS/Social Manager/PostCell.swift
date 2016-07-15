//
//  PostCell.swift
//  Social Manager
//
//  Created by Tomasz Baranowicz on 21/03/16.
//  Copyright © 2016 Direct Solutions. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class PostCell: UITableViewCell {
    
    var taskTextLabel : UILabel?
    var dateLabel : UILabel?
    var statsLabel : UILabel?
    var taskImageView : UIImageView?
    let margin : CGFloat = 10.0
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var cardBackgroundView : UIView?
    
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
        
        self.statsLabel = UILabel(frame: CGRectMake(margin, CGRectGetMaxY(self.taskTextLabel!.frame)+margin, self.frame.size.width-2*margin, 13))
        self.statsLabel!.font = UIFont(name: self.statsLabel!.font.fontName, size: 12)
        self.statsLabel?.textAlignment = NSTextAlignment.Right
        self.statsLabel!.textColor = DARK_GRAY_TEXT_COLOR
        self.contentView.addSubview(statsLabel!)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setPost(task: Post) {
        
        self.taskImageView?.image = nil
        
        if let imagePath = task.media_path {
            taskImageView?.frame = CGRectMake(margin, margin, self.frame.size.width-2*margin, screenSize.size.width/2)
            self.taskTextLabel?.frame = CGRectMake(margin, CGRectGetMaxY(taskImageView!.frame)+margin, self.frame.size.width-2*margin, 20)
            Alamofire.request(.GET, imagePath).responseImage { response in
                if let image = response.result.value {
                    self.taskImageView?.image = image
                }
            }
        } else {
            taskImageView?.frame = CGRectMake(margin, margin, self.frame.size.width-2*margin, 0)
            self.taskTextLabel?.frame = CGRectMake(margin, margin, self.frame.size.width-2*margin, 20)
        }
    
        //text
        self.taskTextLabel?.text = task.text
        self.taskTextLabel?.sizeToFit()
        
        //date
        self.dateLabel?.frame = CGRectMake(margin, CGRectGetMaxY(self.taskTextLabel!.frame)+margin, self.frame.size.width-2*margin, 13)
        self.dateLabel?.text = "\(formatter.stringFromDate(task.date))"
        
        //stats
        self.statsLabel?.frame = CGRectMake(margin, CGRectGetMaxY(self.taskTextLabel!.frame)+margin, self.frame.size.width-2*margin, 13)
        self.statsLabel?.text = "Retweets: \(task.retweet_count!) Likes: \(task.favorite_count!)"
        
        self.cardBackgroundView?.frame = CGRectMake(margin/2, margin/2, self.frame.size.width-margin, CGRectGetMaxY((self.statsLabel!.frame)))
    }
    
    static func cellHeigh(task: Post) -> CGFloat {
        
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
        taskTextLabel.text = task.text
        taskTextLabel.sizeToFit()
        
        height+=taskTextLabel.frame.size.height
        
        height+=margin
        height+=13
        
        height+=margin
        
        
//        print("return height for cell \(height)")
        
        return height
    }
    
}

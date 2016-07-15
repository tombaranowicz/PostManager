//
//  SideMenuViewController.swift
//  Social Manager
//
//  Created by Tomasz Baranowicz on 09/01/16.
//  Copyright © 2016 Direct Solutions. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var accountsTableView: UITableView?
    let accounts : NSMutableArray = NSMutableArray()
    
    @IBAction func signoutAction(sender: UIButton) {
        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_SIGN_OUT, object: nil)
    }
    
    @IBAction func addAccountAction(sender: UIButton) {
        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_ADD_ACCOUNT, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Queue"
        self.accountsTableView!.registerClass(AccountCell.self, forCellReuseIdentifier: "reuseIdentifier")
        self.accountsTableView!.tableFooterView = UIView(frame: CGRect.zero)
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SideMenuViewController.accountsRefreshed), name:NOTIFICATION_ACCOUNTS_REFRESHED, object: nil);
        accountsRefreshed()
    }
    
    func accountsRefreshed() {
        self.accounts.removeAllObjects()
        self.accounts.addObjectsFromArray(DataManager.accounts as [AnyObject])
        self.accountsTableView!.reloadData()
        
        for index in 0 ..< self.accounts.count {
            let account = self.accounts[index] as! Account
            if account.object_id == DataManager.activeAccount?.object_id {
                self.accountsTableView?.selectRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: false, scrollPosition: .None)
            }
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accounts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : AccountCell? = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as? AccountCell
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        let account = accounts.objectAtIndex(indexPath.row) as! Account
        cell!.setAccount(account)
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 94.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  header = UIView(frame: CGRectMake(0,0,200,94))
        header.backgroundColor = LIGHT_GRAY_SEPARATOR_COLOR
        
        let label = UILabel(frame: CGRectMake(0,64,200,30))
        label.text = "Your accounts"
        label.font = UIFont.boldSystemFontOfSize(14)
        label.textColor = BLACK_TEXT_COLOR
        label.textAlignment = NSTextAlignment.Center
        header.addSubview(label)
        
        let footer = UIView(frame: CGRectMake(0,93,200,1))
        footer.backgroundColor = LIGHT_GRAY_SEPARATOR_COLOR
        header.addSubview(footer)
        
        return header
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let account = accounts.objectAtIndex(indexPath.row) as! Account
        DataManager.selectAccount(account)
    }
}

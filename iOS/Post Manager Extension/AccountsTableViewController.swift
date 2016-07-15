//
//  AccountsTableViewController.swift
//  Social Manager
//
//  Created by Tomasz Baranowicz on 02/03/16.
//  Copyright © 2016 Direct Solutions. All rights reserved.
//

import UIKit

protocol AccountsSelector {
    func selectorSelectedAccounts()
}

class AccountsTableViewController: UITableViewController {
    
    var accounts : NSMutableArray = NSMutableArray()
    var selectedAccounts : NSMutableArray = NSMutableArray()
    var accountsSelector : AccountsSelector?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logout = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(AccountsTableViewController.done))
        self.navigationItem.setRightBarButtonItem(logout, animated: true)
        
        self.navigationItem.hidesBackButton = true
        
//        self.title = "Select accounts"
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.tableView.registerClass(AccountCell.self, forCellReuseIdentifier: "reuseIdentifier")
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.reloadData()
    }
    
    func done() {
        if let sel = accountsSelector {
            sel.selectorSelectedAccounts()
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : AccountCell? = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as? AccountCell
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        let account = accounts.objectAtIndex(indexPath.row) as! Account
        cell!.setAccount(account)
        cell!.delegate = self
        cell!.setSwitch(selectedAccounts.containsObject(account), tag: indexPath.row)
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell : AccountCell = tableView.cellForRowAtIndexPath(indexPath) as! AccountCell
        cell.setSwitch(!cell.selectSwitch!.on, tag: indexPath.row)
    }
}

extension AccountsTableViewController : AccountCellDelegate {
    func switchedCell(cell: AccountCell) {
        if cell.selectSwitch!.on && cell.acc != nil && !self.selectedAccounts.containsObject(cell.acc!) {
            self.selectedAccounts.addObject(cell.acc!)
        } else if !cell.selectSwitch!.on && cell.acc != nil {
            self.selectedAccounts.removeObject(cell.acc!)
        }
    }
}

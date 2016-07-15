//
//  ViewController.swift
//  Social Manager
//
//  Created by Tomasz Baranowicz on 13/11/15.
//  Copyright © 2015 Direct Solutions. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

enum ListMode: Int {
    case Planned = 0, Posted
}

class ViewController: BaseViewController {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    var segmentController: UISegmentedControl?
    @IBOutlet weak var emptyView: UIView?
    @IBOutlet weak var clockLabel: UILabel?
    
    @IBOutlet weak var tasksTableView: UITableView?
    var refreshControl = UIRefreshControl()
    var tasks : NSMutableArray = []
    
    @IBOutlet weak var postsTableView: UITableView?
    var postsRefreshControl = UIRefreshControl()
    var posts : NSMutableArray = []
    
    var lastId : Int?
    var lastPage = false
    var requestInProgress = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        
        self.tasksTableView!.registerClass(TaskCell.self, forCellReuseIdentifier: "reuseIdentifier")
        self.tasksTableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tasksTableView?.backgroundColor = UIColor.init(white: 0.92, alpha: 1)
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(ViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
        self.tasksTableView?.addSubview(refreshControl)
        
        self.postsTableView!.registerClass(PostCell.self, forCellReuseIdentifier: "reuseIdentifier2")
        self.postsTableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        self.postsTableView?.backgroundColor = UIColor.init(white: 0.92, alpha: 1)
        
        self.postsRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.postsRefreshControl.addTarget(self, action: #selector(ViewController.postsRefresh), forControlEvents: UIControlEvents.ValueChanged)
        self.postsTableView?.addSubview(postsRefreshControl)
        
        self.clockLabel?.font = UIFont.fontAwesomeOfSize(100)
        self.clockLabel?.text = String.fontAwesomeIconWithName(FontAwesome.ClockO)
        
        if (defaults.stringForKey("token") == nil)
        {
            showLoginScreen()
        }
        
        segmentController = UISegmentedControl(items: ["Planned", "Posted"])
        segmentController?.selectedSegmentIndex = 0
        segmentController?.addTarget(self, action: #selector(ViewController.segmentSwitched), forControlEvents: UIControlEvents.ValueChanged)
        segmentController?.tintColor = DARK_GRAY_TEXT_COLOR
        self.navigationItem.titleView = segmentController
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.forceDataRefresh), name:NOTIFICATION_ACCOUNT_SWITCHED, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.postsRefresh), name:NOTIFICATION_ACCOUNTS_REFRESHED, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.handleQuickActionCompose), name:NOTIFICATION_QUICK_ACTION_COMPOSE, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.signOutNotificationHandler(_:)), name:NOTIFICATION_SIGN_OUT, object: nil)
        
        let rate = RateMyApp.sharedInstance
        rate.appID = "1080440643"
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            rate.trackAppUsage()
        })
    }
    
    func signOutNotificationHandler(notification: NSNotification){
        tasks.removeAllObjects()
        tasksTableView?.reloadData()
        
        posts.removeAllObjects()
        postsTableView?.reloadData()
    }
    
    func segmentSwitched() {
        print("switched to \(segmentController!.selectedSegmentIndex)")
        
        if segmentController?.selectedSegmentIndex == ListMode.Planned.rawValue {
            self.tasksTableView?.hidden = false
        } else {
            self.tasksTableView?.hidden = true
        }
        refreshTableView()
    }
    
    func refreshTasks() {
        PKHUD.sharedHUD.show()
        DataManager.refreshTasks { (tasks) -> Void in
            self.tasks = NSMutableArray.init(array: tasks)
            self.refreshTableView()
            self.refreshControl.endRefreshing()
            PKHUD.sharedHUD.hide()
        }
    }
    
    func handleQuickActionCompose() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        print("check if open creator \(appDelegate.openCreator)")
        if appDelegate.openCreator && defaults.stringForKey("token") != nil {
            appDelegate.openCreator = false
            compose()
        }
    }
    
    func showLoginScreen() {
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("loginViewController") as! LoginViewController
        self.navigationController?.presentViewController(viewController, animated: true, completion: { () -> Void in})
    }
    
    @IBAction func createAction(sender: UIButton) {
        compose()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        logScreen("Queue Screen")
        forceDataRefresh()
        handleQuickActionCompose()
    }
    
    func forceDataRefresh() {
        lastId = nil
        lastPage = false
        refresh()
        postsRefresh()
    }
    
    func refresh() {
        if DataManager.accounts.count == 0 {
            DataManager.refreshAccounts({(accounts: NSMutableArray) -> Void in
                self.refreshTasks()
            })
        } else {
            refreshTasks()
        }
    }
    
    func postsRefresh() {
        guard (DataManager.activeAccount != nil && !requestInProgress && !lastPage)
        else { return }
        
        requestInProgress = true
        AppDataManager.getPostsForActiveAccount(lastId) { (posts: NSMutableArray) -> Void in
            print("user statuses \(posts.count)")
            
            if self.lastId == nil {
                self.posts = posts
            } else {
                if posts.count>0 {
                    posts.removeObjectAtIndex(0)
                    self.posts.addObjectsFromArray(posts as [AnyObject])
                }
            }
            
            if posts.count == 0 { //< AppDataManager.PAGE_SIZE {
                self.lastPage = true
            } else if let post = self.posts.lastObject as? Post {
                self.lastId = post.object_id
            }
            self.postsTableView?.reloadData()
            self.requestInProgress = false
        }
    }
    
    func refreshTableView() {
        self.tasksTableView?.reloadData()
        
        if self.tasks.count == 0 && segmentController?.selectedSegmentIndex == ListMode.Planned.rawValue {
            self.emptyView?.hidden = false
        } else {
            self.emptyView?.hidden = true
        }
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tasksTableView {
            return tasks.count
        }
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == self.tasksTableView {
            let cell : TaskCell? = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as? TaskCell
            cell?.selectionStyle = .None
            let task = tasks.objectAtIndex(indexPath.row) as! Task
            cell!.setTask(task)
            return cell!
        }
        
        if indexPath.row == self.posts.count-1 {
            postsRefresh()
        }
        
        let cell : PostCell? = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier2", forIndexPath: indexPath) as? PostCell
        cell?.selectionStyle = .None
        let post = posts.objectAtIndex(indexPath.row) as! Post
        cell!.setPost(post)
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == self.tasksTableView {
            let task = tasks.objectAtIndex(indexPath.row) as! Task
            return TaskCell.cellHeigh(task)
        }
        
        let post = posts.objectAtIndex(indexPath.row) as! Post
        return PostCell.cellHeigh(post)
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if tableView == self.tasksTableView {
            let task = tasks.objectAtIndex(indexPath.row) as! Task
            
            let alertController = UIAlertController(title: task.message, message: task.readableDate(), preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                // ...
            }
            alertController.addAction(cancelAction)
            
            let OKAction = UIAlertAction(title: "Delete", style: .Default) { (action) in
                self.tasks.removeObject(task)
                self.refreshTableView()
                DataManager.deleteTask(task, callback: { (completed) -> Void in })
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true) {}
        } else {
            
            PKHUD.sharedHUD.show()
            
            let post = posts.objectAtIndex(indexPath.row) as! Post
            
            if let imagePath = post.media_path {
                Alamofire.request(.GET, imagePath).responseImage { response in
                    if let image = response.result.value {
                        self.compose(image, text: post.text)
                        PKHUD.sharedHUD.hide()
                    } else {
                        self.compose(nil, text: post.text)
                        PKHUD.sharedHUD.hide()
                    }
                }
            } else {
                self.compose(nil, text: post.text)
                PKHUD.sharedHUD.hide()
            }
        }
    }
}
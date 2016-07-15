//
//  ScheduleViewController.swift
//  Social Manager
//
//  Created by Tomasz Baranowicz on 05/03/16.
//  Copyright © 2016 Direct Solutions. All rights reserved.
//

import UIKit

protocol DateSelector {
    func selectorSelectedDate(date: NSDate)
}

class ScheduleViewController: UIViewController {

    var selectedDate: NSDate?
    var dateSelector : DateSelector?
    var datepicker : UIDatePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logout = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(ScheduleViewController.done))
        self.navigationItem.setRightBarButtonItem(logout, animated: true)
        
        self.navigationItem.hidesBackButton = true
        
//        self.title = "Schedule Post"
        
        self.view.backgroundColor = UIColor.whiteColor()
        datepicker = UIDatePicker(frame:CGRectMake(0, 0, self.view.frame.size.width, 220));
        datepicker!.datePickerMode = UIDatePickerMode.DateAndTime;
        datepicker!.minimumDate = NSDate()
        self.view.addSubview(datepicker!);
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.selectedDate != nil {
            datepicker?.date = self.selectedDate!
        }
    }
    
    func done() {
        
        if let sel = dateSelector {
            sel.selectorSelectedDate(self.datepicker!.date)
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
}

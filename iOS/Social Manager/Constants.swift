//
//  Constants.swift
//  OAuthSwift
//
//  Created by Dongri Jin on 7/17/14.
//  Copyright (c) 2014 Dongri Jin. All rights reserved.
//

import Foundation
import UIKit

let SHARED_DEFAULTS = "group.net.postmanager.iphone"

let DARK_GRAY_TEXT_COLOR = UIColor.darkGrayColor()
let BLACK_TEXT_COLOR = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)

let LIGHT_GRAY_SEPARATOR_COLOR = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)

let NAVY_BLUE_COLOR = UIColor(red: 2.0/255.0, green: 22.0/255.0, blue: 37.0/255.0, alpha: 1.0)
let GREEN_COLOR = UIColor(red: 34.0/255.0, green: 255.0/255.0, blue: 189.0/255.0, alpha: 1.0)

let TWITTER_COLOR = UIColor(red: 85.0/255.0, green: 172.0/255.0, blue: 238.0/255.0, alpha: 1.0)

#if DEBUG
    let SERVER_BASE_URL = "http://localhost"
#else
    let SERVER_BASE_URL = "http://postmanager.net"
#endif

let NOTIFICATION_SIGN_OUT = "SignOutNotificationIdentifier"
let NOTIFICATION_ADD_ACCOUNT = "AddAccountNotificationIdentifier"
let NOTIFICATION_ACCOUNTS_REFRESHED = "AccountsRefreshedNotificationIdentifier"
let NOTIFICATION_ACCOUNT_SWITCHED = "AccountSwitchedNotificationIdentifier"

let NOTIFICATION_QUICK_ACTION_COMPOSE = "QuickActionComposeNotificationIdentifier"

let TOKEN_KEY = "token"
let SELECTED_ACCOUNT_ID = "selected_account_id"

let Twitter =
[
    "consumerKey": "TODO_YOUR_DATA",
    "consumerSecret": "TODO_YOUR_DATA"
]
let Salesforce =
[
    "consumerKey": "***",
    "consumerSecret": "***"
]
let Flickr =
[
    "consumerKey": "***",
    "consumerSecret": "***"
]
let Github =
[
    "consumerKey": "***",
    "consumerSecret": "***"
]
let Instagram =
[
    "consumerKey": "***",
    "consumerSecret": "***"
]
let Foursquare =
[
    "consumerKey": "***",
    "consumerSecret": "***"
]
let Fitbit =
[
    "consumerKey": "***",
    "consumerSecret": "***"
]
let Withings =
[
    "consumerKey": "***",
    "consumerSecret": "***"
]
let Linkedin =
[
    "consumerKey": "***",
    "consumerSecret": "***"
]
let Linkedin2 =
[
    "consumerKey": "***",
    "consumerSecret": "***"
]
let Dropbox =
[
    "consumerKey": "***",
    "consumerSecret": "***"
]
let Dribbble =
[
    "consumerKey": "***",
    "consumerSecret": "***"
]
let BitBucket =
[
    "consumerKey": "***",
    "consumerSecret": "***"
]
let GoogleDrive =
[
    "consumerKey": "***",
    "consumerSecret": "***"
]
let Smugmug =
[
    "consumerKey": "***",
    "consumerSecret": "***"
]
let Intuit =
[
    "consumerKey": "***",
    "consumerSecret": "***"
]
let Zaim =
[
    "consumerKey": "***",
    "consumerSecret": "***"
]
let Tumblr =
[
    "consumerKey": "***",
    "consumerSecret": "***"
]
let Slack =
[
    "consumerKey": "***",
    "consumerSecret": "***"
]
let Uber =
[
    "consumerKey": "***",
    "consumerSecret": "***"
]

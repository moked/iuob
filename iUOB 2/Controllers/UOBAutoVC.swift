//
//  UOBAutoVC.swift
//  iUOB 2
//
//  Created by Miqdad Altaitoon on 8/14/16.
//  Copyright © 2016 Miqdad Altaitoon. All rights reserved.
//

import UIKit

/* COMMING LATER */

class UOBAutoVC: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleAnalytics()
    }

    func googleAnalytics() {
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!)
            let builder = GAIDictionaryBuilder.createScreenView()
            tracker.send(builder.build() as [NSObject : AnyObject])
        }
    }

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        // Display a message when the table is empty
        let messageLabel: UILabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        messageLabel.text = "Comming Soon.."
        messageLabel.textColor = UIColor.blackColor()
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .Center
        messageLabel.sizeToFit()
        self.tableView.backgroundView = messageLabel
        self.tableView.separatorStyle = .None
        
        return 0;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AutoCell", forIndexPath: indexPath)

        return cell
    }
}

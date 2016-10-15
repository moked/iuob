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
            tracker.set(kGAIScreenName, value: NSStringFromClass(type(of: self)).components(separatedBy: ".").last!)
            let builder: NSObject = GAIDictionaryBuilder.createScreenView().build()
            tracker.send(builder as! [NSObject : AnyObject])
        }
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        // Display a message when the table is empty
        let messageLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        messageLabel.text = "Comming Soon.."
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.sizeToFit()
        self.tableView.backgroundView = messageLabel
        self.tableView.separatorStyle = .none
        
        return 0;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AutoCell", for: indexPath)

        return cell
    }
}

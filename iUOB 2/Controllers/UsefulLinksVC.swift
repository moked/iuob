//
//  UsefulLinksVC.swift
//  iUOB 2
//
//  Created by Miqdad Altaitoon on 9/13/16.
//  Copyright © 2016 Miqdad Altaitoon. All rights reserved.
//

import UIKit
import SafariServices

class UsefulLinksVC: UITableViewController, SFSafariViewControllerDelegate {

    // MARK: - Properties
    
    var links: [Link] = []
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        googleAnalytics()
        
        links.append(Link(name: "iUOB", url: "http://iuob.net"))
        links.append(Link(name: "UOB Website", url: "http://www.uob.edu.bh"))
        links.append(Link(name: "Enrollment", url: "http://www.online.uob.edu.bh/cgi/enr/all_enroll"))
        links.append(Link(name: "Exam Location", url: "http://www.online.uob.edu.bh/cgi/enr/examtable.exam"))
        links.append(Link(name: "Blackboard", url: "http://bb.uob.edu.bh"))
        links.append(Link(name: "Phonebook", url: "http://dir.uob.edu.bh/mainEn.aspx"))
    }

    func googleAnalytics() {
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!)
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return links.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LinkCell", forIndexPath: indexPath)

        cell.textLabel?.text = links[indexPath.row].name
        cell.detailTextLabel?.text = links[indexPath.row].url

        return cell
    }
 
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let safariVC = SFSafariViewController(URL:NSURL(string: links[indexPath.row].url)!, entersReaderIfAvailable: true)
        safariVC.delegate = self
        self.presentViewController(safariVC, animated: true, completion: nil)
    }
}

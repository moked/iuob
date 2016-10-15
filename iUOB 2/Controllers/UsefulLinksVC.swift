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
        links.append(Link(name: "Academic Calendar", url: "http://offline.uob.edu.bh/pages.aspx?module=pages&id=5366&SID=868"))
        links.append(Link(name: "Phonebook", url: "http://dir.uob.edu.bh/mainEn.aspx"))
    }

    func googleAnalytics() {
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: NSStringFromClass(type(of: self)).components(separatedBy: ".").last!)
            let builder: NSObject = GAIDictionaryBuilder.createScreenView().build()
            tracker.send(builder as! [NSObject : AnyObject])
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return links.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LinkCell", for: indexPath)

        cell.textLabel?.text = links[(indexPath as NSIndexPath).row].name
        cell.detailTextLabel?.text = links[(indexPath as NSIndexPath).row].url

        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let safariVC = SFSafariViewController(url:URL(string: links[(indexPath as NSIndexPath).row].url)!, entersReaderIfAvailable: true)
        safariVC.delegate = self
        self.present(safariVC, animated: true, completion: nil)
    }
}

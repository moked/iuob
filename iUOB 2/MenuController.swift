//
//  MenuController.swift
//  Example
//
//  Created by Teodor Patras on 16/06/16.
//  Copyright © 2016 teodorpatras. All rights reserved.
//

import UIKit

class MenuController: UITableViewController {
    
    let segues = ["showCenterController", "showScheduleBuilderController", "showMapController", "showUsefulLinksController", "showAboutController"];
    let names = ["Semester Schedule", "Schedule Builder", "UOB Map", "Useful Links", "About"]
    private var previousIndex: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return segues.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("menuCell")!
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
        cell.textLabel?.text = names[indexPath.row]
        
        cell.imageView?.image = UIImage(named: names[indexPath.row])
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let index = previousIndex {
            tableView.deselectRowAtIndexPath(index, animated: true)
        }
        
        sideMenuController?.performSegueWithIdentifier(segues[indexPath.row], sender: nil)
        previousIndex = indexPath
    }
}

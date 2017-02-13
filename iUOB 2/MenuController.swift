//
//  MenuController.swift
//  Example
//
//  Created by Teodor Patras on 16/06/16.
//  Copyright © 2016 teodorpatras. All rights reserved.
//

import UIKit

class MenuController: UITableViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    
    let segues = ["showCenterController", "showStudentScheduleController", "showScheduleBuilderController", "showMapController", "showUsefulLinksController", "showAboutController"];
    let names = ["Semester Schedule", "My Schedule", "Schedule Builder", "UOB Map", "Useful Links", "About"]
    fileprivate var previousIndex: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoImageView.layer.cornerRadius = 16

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return segues.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell")!
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
        cell.textLabel?.text = names[(indexPath as NSIndexPath).row]
        
        cell.imageView?.image = UIImage(named: names[(indexPath as NSIndexPath).row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let index = previousIndex {
            tableView.deselectRow(at: index, animated: true)
        }
        
        sideMenuController?.performSegue(withIdentifier: segues[(indexPath as NSIndexPath).row], sender: nil)
        previousIndex = indexPath
    }
}

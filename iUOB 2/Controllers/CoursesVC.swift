//
//  CoursesVC.swift
//  iUOB 2
//
//  Created by Miqdad Altaitoon on 8/10/16.
//  Copyright © 2016 Miqdad Altaitoon. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD

class CoursesVC: UITableViewController {

    // MARK: - Properties
    
    var department:Department!
    var courses: [Course] = []
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleAnalytics()

        self.title = department.name
        
        getCourses()
    }
    
    func googleAnalytics() {
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!)
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    // MARK: - Load Data
    
    func getCourses() {
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        Alamofire.request(.GET, department.url, parameters: nil)
            .validate()
            .responseString { response in
                
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
                if response.result.error == nil {

                    self.courses = UOBParser.parseCourses(response.result.value!)
                    
                    self.tableView.reloadData()
                } else {
                    print("error man")
                }
        }
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CourseCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = "\(courses[indexPath.row].code) - \(courses[indexPath.row].name)"
        cell.detailTextLabel?.text = courses[indexPath.row].preRequisite

        return cell
    }

    // Mark: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowTiming" {
            
            let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell)! as NSIndexPath
                        
            let destinationViewController = segue.destinationViewController as! TimingVC
            
            destinationViewController.course = courses[indexPath.row]
        }
    }
}

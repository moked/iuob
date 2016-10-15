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
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: NSStringFromClass(type(of: self)).components(separatedBy: ".").last!)
            let builder: NSObject = GAIDictionaryBuilder.createScreenView().build()
            tracker.send(builder as! [NSObject : AnyObject])
        }
    }
    
    // MARK: - Load Data
    
    func getCourses() {
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        Alamofire.request(department.url, parameters: nil)
            .validate()
            .responseString { response in
                
                MBProgressHUD.hide(for: self.view, animated: true)
                
                if response.result.error == nil {

                    self.courses = UOBParser.parseCourses(response.result.value!)
                    
                    self.tableView.reloadData()
                } else {
                    print("error man")
                }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath)
        
        cell.textLabel?.text = "\(courses[(indexPath as NSIndexPath).row].code) - \(courses[(indexPath as NSIndexPath).row].name)"
        cell.detailTextLabel?.text = courses[(indexPath as NSIndexPath).row].preRequisite

        return cell
    }

    // Mark: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTiming" {
            
            let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell)! as IndexPath
                        
            let destinationViewController = segue.destination as! TimingVC
            
            destinationViewController.course = courses[(indexPath as NSIndexPath).row]
        }
    }
}

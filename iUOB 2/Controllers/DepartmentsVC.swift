//
//  DepartmentsVC.swift
//  iUOB 2
//
//  Created by Miqdad Altaitoon on 8/8/16.
//  Copyright © 2016 Miqdad Altaitoon. All rights reserved.
//

import UIKit
import SideMenuController
import BTNavigationDropdownMenu
import Alamofire
import Kanna
import MBProgressHUD

class DepartmentsVC: UITableViewController {

    // MARK: - Properties
    
    var menuView: BTNavigationDropdownMenu!
    
    var departments: [Department] = []
    var letters: [Character] = []
    var deptDictianry = [Character: [Department]]()

    // MARK: - Life Cycle
    
    required init?(coder aDecoder: NSCoder) {
        
        SideMenuController.preferences.drawing.menuButtonImage = UIImage(named: "menu")
        SideMenuController.preferences.drawing.sidePanelPosition = .UnderCenterPanelLeft
        
        SideMenuController.preferences.drawing.sidePanelWidth = 300
        SideMenuController.preferences.drawing.centerPanelShadow = true
        SideMenuController.preferences.animating.statusBarBehaviour = .HorizontalPan
        SideMenuController.preferences.animating.transitionAnimator = FadeAnimator.self
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleAnalytics()
        registerForPush()
        
        let items = ["2016/1"]  // will add an algorithm to determine the semester later
        
        menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: items[0], items: items)
        menuView.arrowTintColor = UIColor.blackColor()

        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            //self.selectedCellLabel.text = items[indexPath]
        }
        
        self.navigationItem.titleView = menuView
        
        getDepartments()
    }
    
    func registerForPush() {
        
        let application = UIApplication.sharedApplication()

        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
    }
    
    func googleAnalytics() {
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!)
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    // MARK: - Load Data
    
    func getDepartments() {

        let url = "\(Constants.baseURL)/cgi/enr/schedule2.abrv"
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        Alamofire.request(.GET, url, parameters: ["prog": "1", "cyer": "2016", "csms": "1"])    // this shouldn't be hard coded
            .validate()
            .responseString { response in
                
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
                if response.result.error == nil {
                    
                    self.departments = UOBParser.parseDepartments(response.result.value!)
                    
                    self.buildLettersDictionary()
                    
                } else {
                    print("error man")
                }
        }
    }
    
    func buildLettersDictionary() {
        
        // Build letters array:
        
        letters = departments.map { (department) -> Character in
            return department.name[department.name.startIndex]
        }
        
        letters = letters.sort()
        
        letters = letters.reduce([], combine: { (list, name) -> [Character] in
            if !list.contains(name) {
                return list + [name]
            }
            return list
        })
        
        // Build departments array:
        
        for entry in departments {
            
            if deptDictianry[entry.name[entry.name.startIndex]] == nil {
                deptDictianry[entry.name[entry.name.startIndex]] = [Department]()
            }
            
            deptDictianry[entry.name[entry.name.startIndex]]!.append(entry)
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return letters.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deptDictianry[letters[section]]!.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(letters[section])"
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        
        var indexes = [String]()
        for l in letters {
            indexes.append("\(l)")
        }
        return indexes
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
           
        let cell = tableView.dequeueReusableCellWithIdentifier("DepartmentCell", forIndexPath: indexPath)
        
        let dep = deptDictianry[letters[indexPath.section]]![indexPath.row]
        
        cell.textLabel?.text = dep.name
        
        return cell
    }

    // Mark: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowCourses" {
            
            let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell)! as NSIndexPath
            
            let dep = deptDictianry[letters[indexPath.section]]![indexPath.row]
            
            let destinationViewController = segue.destinationViewController as! CoursesVC
            
            destinationViewController.department = dep
        }
    }
}

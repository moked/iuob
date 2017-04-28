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
import NYAlertViewController

class DepartmentsVC: UITableViewController {

    // MARK: - Properties
    
    var menuView: BTNavigationDropdownMenu!
    
    var departments: [Department] = []
    var letters: [Character] = []
    var deptDictianry = [Character: [Department]]()

    // MARK: - Life Cycle
    
    required init?(coder aDecoder: NSCoder) {
        
        SideMenuController.preferences.drawing.menuButtonImage = UIImage(named: "menu")
        SideMenuController.preferences.drawing.sidePanelPosition = .underCenterPanelLeft
        
        SideMenuController.preferences.drawing.sidePanelWidth = 300
        SideMenuController.preferences.drawing.centerPanelShadow = true
        
        SideMenuController.preferences.animating.statusBarBehaviour = .horizontalPan
        SideMenuController.preferences.animating.transitionAnimator = FadeAnimator.self
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleAnalytics()
        registerForPush()
        
        let items = ["2016/2"]  // will add an algorithm to determine the semester later
        
        menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: items[0], items: items as [AnyObject])
        menuView.arrowTintColor = UIColor.black

        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            //self.selectedCellLabel.text = items[indexPath]
        }
        
        self.navigationItem.titleView = menuView
        
        getDepartments()
    }
    
    func registerForPush() {
        
        let application = UIApplication.shared

        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
    }
    
    func googleAnalytics() {
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: NSStringFromClass(type(of: self)).components(separatedBy: ".").last!)
            let builder: NSObject = GAIDictionaryBuilder.createScreenView().build()
            tracker.send(builder as! [NSObject : AnyObject])
        }
    }
    
    // MARK: - Load Data
    
    func getDepartments() {

        let url = "\(Constants.baseURL)/cgi/enr/schedule2.abrv"
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        Alamofire.request(url, method: .get, parameters: ["prog": "1", "cyer": "2016", "csms": "2"])    // this shouldn't be hard coded
            .validate()
            .responseString { response in
                
                MBProgressHUD.hide(for: self.view, animated: true)
                
                if response.result.error == nil {
                    
                    self.departments = UOBParser.parseDepartments(response.result.value!)
                    
                    self.buildLettersDictionary()
                    
                } else {
                    print("error man")
                    self.showAlert(title: "Error", msg: (response.result.error?.localizedDescription)!)
                }
        }
    }
    
    func buildLettersDictionary() {
        
        // Build letters array:
        
        letters = departments.map { (department) -> Character in
            return department.name[department.name.startIndex]
        }
        
        letters = letters.sorted()
        
        letters = letters.reduce([], { (list, name) -> [Character] in
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
    
    func showAlert(title: String, msg: String) {
        
        let alertViewController = NYAlertViewController()
        
        alertViewController.title = title
        alertViewController.message = msg
        
        alertViewController.buttonCornerRadius = 20.0
        alertViewController.view.tintColor = self.view.tintColor
        
        //alertViewController.cancelButtonColor = UIColor.redColor()
        alertViewController.destructiveButtonColor = UIColor(netHex:0xFFA739)
        
        alertViewController.swipeDismissalGestureEnabled = true
        alertViewController.backgroundTapDismissalGestureEnabled = true
        
        
        let cancelAction = NYAlertAction(
            title: "Close",
            style: .cancel,
            handler: { (action: NYAlertAction?) -> Void in
                self.dismiss(animated: true, completion: nil)
                
        }
        )
        
        alertViewController.addAction(cancelAction)
        
        
        // Present the alert view controller
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return letters.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deptDictianry[letters[section]]!.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(letters[section])"
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        var indexes = [String]()
        for l in letters {
            indexes.append("\(l)")
        }
        return indexes
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           
        let cell = tableView.dequeueReusableCell(withIdentifier: "DepartmentCell", for: indexPath)
        
        let dep = deptDictianry[letters[(indexPath as NSIndexPath).section]]![(indexPath as NSIndexPath).row]
        
        cell.textLabel?.text = dep.name
        
        return cell
    }

    // Mark: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowCourses" {
            
            let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell)! as IndexPath
            
            let dep = deptDictianry[letters[(indexPath as NSIndexPath).section]]![(indexPath as NSIndexPath).row]
            
            let destinationViewController = segue.destination as! CoursesVC
            
            destinationViewController.department = dep
        }
    }
}

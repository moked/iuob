//
//  AddCoursesVC.swift
//  iUOB 2
//
//  Created by Miqdad Altaitoon on 9/26/16.
//  Copyright © 2016 Miqdad Altaitoon. All rights reserved.
//

import UIKit
import NYAlertViewController

class AddCoursesVC: UITableViewController {

    // MARK: - Properties
    
    var courses: [String] = []
    var sections: [String] = []
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleAnalytics()
        
        reloadZeData()
    }
    
    func googleAnalytics() {
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: NSStringFromClass(type(of: self)).components(separatedBy: ".").last!)
            let builder: NSObject = GAIDictionaryBuilder.createScreenView().build()
            tracker.send(builder as! [NSObject : AnyObject])
        }
    }
    
    func googleTrackEvent() {
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            let builder: NSObject = GAIDictionaryBuilder.createEvent(withCategory: "AddCourse", action: "AddCourse", label: "AddCourse", value: 1).build()
            tracker.send(builder as! [NSObject : AnyObject])
        }
    }
    
    @IBAction func addNewCourse(_ sender: AnyObject) {
        
        let alertViewController = NYAlertViewController()
        
        alertViewController.title = "Add course"
        alertViewController.message = "Please write the course and section:"
        
        alertViewController.buttonCornerRadius = 20.0
        alertViewController.view.tintColor = self.view.tintColor
        
        //alertViewController.cancelButtonColor = UIColor.redColor()
        alertViewController.destructiveButtonColor = UIColor(netHex:0xFFA739)
        
        alertViewController.swipeDismissalGestureEnabled = true
        alertViewController.backgroundTapDismissalGestureEnabled = true
        

        let cancelAction = NYAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: { (action: NYAlertAction?) -> Void in
                self.dismiss(animated: true, completion: nil)

            }
        )
        
        let addAction = NYAlertAction(
            title: "Add",
            style: .destructive,
            handler: { (action: NYAlertAction?) -> Void in
                
                self.dismiss(animated: true, completion: nil)
                
                var courseStr = ""
                var sectionStr = ""
                
                if let course = alertViewController.textFields[0] as? UITextField {
                    courseStr = course.text!
                }
                
                if let section = alertViewController.textFields[1] as? UITextField {
                    sectionStr = section.text!
                }
                
                if courseStr.characters.count > 0 && sectionStr.characters.count > 0 {
                    
                    if sectionStr.characters.count == 1 {
                        sectionStr = "0\(sectionStr)"   // add leading zero in case of single digit
                    }
                    
                    Constants.addToUserDefaults(courseStr, section: sectionStr)
                    self.googleTrackEvent()
                    
                    self.reloadZeData()
                } else {
                    print("no data")
                }
            }
        )
        
        alertViewController.addAction(addAction)
        alertViewController.addAction(cancelAction)
        
        alertViewController.addTextField(configurationHandler: { (textField: UITextField?) -> Void in
            
            textField!.autocorrectionType = .no
            textField!.autocapitalizationType = .allCharacters
            textField!.placeholder = "Course e.g: HIST122"
            textField!.font = UIFont(name: "AvenirNext-Regular", size: 16.0)
        })
        

        alertViewController.addTextField(configurationHandler: { (textField: UITextField?) -> Void in
            
            textField!.keyboardType = .numberPad
            textField!.autocorrectionType = .no
            textField!.placeholder = "Section e.g: 01"
            textField!.font = UIFont(name: "AvenirNext-Regular", size: 16.0)
        })
        

        // Present the alert view controller
        self.present(alertViewController, animated: true, completion: nil)
    }

    func reloadZeData() {
        
        let hamburger = Constants.getCoursesAndSections()
        
        self.courses = hamburger.courses
        self.sections = hamburger.sections
        
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath)

        cell.textLabel?.text = courses[(indexPath as NSIndexPath).row]
        cell.detailTextLabel?.text = "Section: \(sections[(indexPath as NSIndexPath).row])"

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            
            Constants.deleteFromUserDefaults(index: indexPath.row)
            reloadZeData()
        }
    }
    
}

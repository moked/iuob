//
//  SectionsFilterVC.swift
//  iUOB 2
//
//  Created by Miqdad Altaitoon on 12/18/16.
//  Copyright © 2016 Miqdad Altaitoon. All rights reserved.
//

import UIKit

class SectionsFilterVC: UITableViewController {

    // MARK: - Properties
    
    var courseSectionDict = [String: [Section]]()
    var filteredCourseSectionDict = [String: [Section]]()

    var filterChanged = false
    
    // MARK: - Life Cycle
    
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

        return courseSectionDict.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let key = Array(courseSectionDict.keys)[section]
        return courseSectionDict[key]!.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor(netHex:0x884403)
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(Array(courseSectionDict.keys)[section]) - \(courseSectionDict[Array(courseSectionDict.keys)[section]]!.count) Sections"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sectionCell", for: indexPath)

        let key = Array(courseSectionDict.keys)[indexPath.section]
        let sections = courseSectionDict[key]!
        let selSection = sections[indexPath.row]
        
        var sectionFound = false
        let filteredSections = filteredCourseSectionDict[key]!
        for aSection in filteredSections {
            if aSection.sectionNo == selSection.sectionNo {
                sectionFound = true
                break
            }
        }
        if sectionFound {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        cell.textLabel?.text = "[\(selSection.sectionNo)] \(selSection.doctor)"
        
        var timeDetails = ""
        
        for timing in selSection.timing {
            
            timeDetails += "[\(timing.day) \(timing.timeFrom)-\(timing.timeTo)] "
        }
        
        cell.detailTextLabel?.text = timeDetails

        return cell
    }
 

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        filterChanged = true
        
        let cell = tableView.cellForRow(at: indexPath)!
        
        let key = Array(courseSectionDict.keys)[indexPath.section]
        let sections = courseSectionDict[key]!
        let selSection = sections[indexPath.row]
        var filteredSections = filteredCourseSectionDict[key]!

        var sectionFound = false
        for i in 0..<filteredSections.count {
            if filteredSections[i].sectionNo == selSection.sectionNo {
                filteredSections.remove(at: i)
                cell.accessoryType = .none
                sectionFound = true
                break
            }
        }
        
        if !sectionFound {
            // added it now
            filteredSections.append(selSection)
            cell.accessoryType = .checkmark
        }
        
        filteredCourseSectionDict[key]! = filteredSections
  
        tableView.deselectRow(at: indexPath, animated: true)
    }

    @IBAction func actionMenuButton(_ sender: Any) {
        
        let alert = UIAlertController(title: "Select", message: "Please Select an Option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Select All", style: .default , handler:{ (UIAlertAction)in
            
            self.filteredCourseSectionDict = self.courseSectionDict
            
            self.tableView.reloadData()
            self.filterChanged = true
        }))
        
        alert.addAction(UIAlertAction(title: "Deselect All", style: .default , handler:{ (UIAlertAction)in
            
            for (key, _) in self.filteredCourseSectionDict {
                
                self.filteredCourseSectionDict[key]! = []
            }
            
            self.tableView.reloadData()
            self.filterChanged = true
        }))
        
        
        alert.addAction(UIAlertAction(title: "Deselect [To Be Announced]", style: .default , handler:{ (UIAlertAction)in
            
            for (key, _) in self.filteredCourseSectionDict {
                
                var filteredSections = [Section]()
                
                for i in 0..<self.filteredCourseSectionDict[key]!.count {
                    if self.filteredCourseSectionDict[key]![i].doctor != "To Be Announced" {
                        filteredSections.append(self.filteredCourseSectionDict[key]![i])
                    }
                }
                
                self.filteredCourseSectionDict[key]! = filteredSections
            }
            
            self.tableView.reloadData()
            self.filterChanged = true
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler:{ (UIAlertAction)in
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
        
    }

}

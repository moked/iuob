//
//  OptionsListVC.swift
//  iUOB 2
//
//  Created by Miqdad Altaitoon on 1/15/17.
//  Copyright © 2017 Miqdad Altaitoon. All rights reserved.
//

import UIKit

class OptionsListVC: UITableViewController {

    var sectionCombination = [[Section]]()

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 58

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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return sectionCombination.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BuilderOptionCell", for: indexPath) as! BuilderOptionCell
        
        cell.optionNumberLabel.text = "\(indexPath.row + 1)"
        
        let sections = sectionCombination[indexPath.row]
        
        var isFirstLine = true
        var summaryText = ""
        
        for section in sections {
            
            if isFirstLine {
                
                summaryText += "[\(section.sectionNo)] \(section.note) 🤓\(shortDrName(doctor: section.doctor)) 🕗"
                
                for timing in section.timing {
                    
                    summaryText += "\(timing.day)\(timing.timeFrom) "
                }
                
                isFirstLine = false
            } else {
                
                summaryText += "\n[\(section.sectionNo)] \(section.note) 🤓\(shortDrName(doctor: section.doctor)) 🕗"
                
                for timing in section.timing {
                    
                    summaryText += "\(timing.day)\(timing.timeFrom) "
                }
            }
        }
        
        cell.summaryLabel.text = summaryText

        return cell
    }
 

    func shortDrName(doctor: String) -> String {
        
        if doctor == "To Be Announced" {
            return doctor
        }
        
        var shortDoctorName = doctor
        
        if doctor.hasPrefix("Dr.") || doctor.hasPrefix("DR.") || doctor.hasPrefix("Mr.") || doctor.hasPrefix("Ms.") {
            
            let suffixIndex = doctor.index(doctor.startIndex, offsetBy: 3)
            shortDoctorName = doctor.substring(from: suffixIndex)
            
        } else if doctor.hasPrefix("Mrs.") {
            
            let suffixIndex = doctor.index(doctor.startIndex, offsetBy: 4)
            shortDoctorName = doctor.substring(from: suffixIndex)
        }
        
        shortDoctorName = shortDoctorName.trimmingCharacters(in: .whitespaces)
        
        let fullNameArr = shortDoctorName.components(separatedBy: " ")
        
        if fullNameArr.count > 1 {
         
            shortDoctorName = "\(fullNameArr[0]) \(fullNameArr.last!)"
        }
        
        return shortDoctorName
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TimetableSegue" {
            
            let selectedIndex = self.tableView.indexPath(for: sender as! BuilderOptionCell)
            
            let nextScene = segue.destination as? BuilderTimeTableVC
            nextScene!.mySections = sectionCombination[selectedIndex!.row]
            
        } else if segue.identifier == "ScheduleDetailsSegue" {
            
            let destinationNavigationController = segue.destination as! UINavigationController
            let nextScene = destinationNavigationController.topViewController as? ScheduleDetailsVC
            
            let selectedIndex = self.tableView.indexPath(for: sender as! BuilderOptionCell)

            nextScene!.sections = sectionCombination[selectedIndex!.row]
        }
    }

}

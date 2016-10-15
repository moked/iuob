//
//  TodayViewController.swift
//  My Schedule
//
//  Created by Miqdad Altaitoon on 10/15/16.
//  Copyright © 2016 Miqdad Altaitoon. All rights reserved.
//

import UIKit
import Foundation
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    // MARK: - Properties
    
    @IBOutlet weak var class1Label: UILabel!
    @IBOutlet weak var class2Label: UILabel!
    @IBOutlet weak var class3Label: UILabel!
    @IBOutlet weak var class4Label: UILabel!
    @IBOutlet weak var class5Label: UILabel!
    @IBOutlet weak var class6Label: UILabel!
    @IBOutlet weak var class7Label: UILabel!

    @IBOutlet weak var dayOfWeekLabel: UILabel!

    var courses: [String] = []
    var sections: [String] = []
    var mySections: [Section] = []
    let messages = ["No classes today yay 😌", "Rest Day 😍", "No UOB today 💃"]

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

       // self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded // prefeared size
        
        hideLabels()
        
        let data = Constants.getCoursesAndSections()
        courses = data.courses
        sections = data.sections
        
        self.dayOfWeekLabel.text = Date().dayOfWeek()!
        
        if courses.count > 0 {
            getNextCourseData(0, cache: true) // get first course
        } else {
            showMessage(msg: "Go to 'My Schedule' in the App to add courses.")
        }
    }
    
    func hideLabels() {
        self.class1Label.isHidden = true
        self.class2Label.isHidden = true
        self.class3Label.isHidden = true
        self.class4Label.isHidden = true
        self.class5Label.isHidden = true
        self.class6Label.isHidden = true
        self.class7Label.isHidden = true
        
        self.class2Label.textAlignment = .left
    }
    
    func showMessage(msg: String) {
        
        self.hideLabels()
        self.class2Label.isHidden = false
        self.class2Label.textAlignment = .center
        self.class2Label.text = msg
    }
    
    func getNextCourseData(_ index: Int, cache: Bool) {
        
        let thisCourse = self.courses[index]
        
        let defaults: UserDefaults = UserDefaults(suiteName: "group.com.muqdd.iuob")!
        if let rawHTML = defaults.object(forKey: "\(self.courses[index])-\(self.sections[index])") as? String {
            
            self.parseResult(html: rawHTML, index: index, cache: cache, course: thisCourse)
        }
    }
    
    func parseResult(html: String, index: Int, cache: Bool, course: String) {
        
        let allSections = UOBParser.parseSections(html)
        
        if allSections.count > 0 {
            
            for section in allSections {
                
                if section.sectionNo == self.sections[index] {
                    
                    self.mySections.append(section)
                    self.mySections[self.mySections.count - 1].note = course
                    
                    break
                }
            }
            
            // here man, load others recuresvly
            if index + 1 < self.courses.count {
                self.getNextCourseData(index + 1, cache: cache)
            } else {
                
                self.createTimeTable()
            }
        }
        
    }
    
    func createTimeTable() {
        
        var sundays = [Section]()
        var mondays = [Section]()
        var tuesdays = [Section]()
        var wednesdays = [Section]()
        var thursdays = [Section]()
        
        /* add sections to thier sigluar day */
        for section in self.mySections {
            for timing in section.timing {
                
                if timing.day.range(of: "U") != nil {
                    var sec = section
                    sec.timing = [timing]   // necessary to eliminate ambiguity
                    sundays.append(sec)
                }
                
                if timing.day.range(of: "M") != nil {
                    var sec = section
                    sec.timing = [timing]
                    mondays.append(sec)
                }
                
                if timing.day.range(of: "T") != nil {
                    var sec = section
                    sec.timing = [timing]
                    tuesdays.append(sec)
                }
                
                if timing.day.range(of: "W") != nil {
                    var sec = section
                    sec.timing = [timing]
                    wednesdays.append(sec)
                }
                
                if timing.day.range(of: "H") != nil {
                    var sec = section
                    sec.timing = [timing]
                    thursdays.append(sec)
                }
            }
        }
        
        /* sort timing for each day */
        sundays = sundays.sorted { $0.timing[0].timeFrom < $1.timing[0].timeFrom }      // omg. that's why I love Swift <3
        mondays = mondays.sorted { $0.timing[0].timeFrom < $1.timing[0].timeFrom }
        tuesdays = tuesdays.sorted { $0.timing[0].timeFrom < $1.timing[0].timeFrom }
        wednesdays = wednesdays.sorted { $0.timing[0].timeFrom < $1.timing[0].timeFrom }
        thursdays = thursdays.sorted { $0.timing[0].timeFrom < $1.timing[0].timeFrom }
        
        self.dayOfWeekLabel.text = Date().dayOfWeek()!

        switch Date().dayOfWeek()! {
        case "Sun":
            updateData(sections: sundays)
        case "Mon":
            updateData(sections: mondays)
        case "Tue":
            updateData(sections: tuesdays)
        case "Wed":
            updateData(sections: wednesdays)
        case "Thu":
            updateData(sections: thursdays)
        case "Fri":
            noClassesToday()
        case "Sat":
            noClassesToday()
        default:
            noClassesToday()
        }

    }
    
    func noClassesToday() {
        
        let rand = Int(arc4random_uniform(UInt32(messages.count)))
        showMessage(msg: messages[rand])
    }
    
    func updateData(sections: [Section]) {
        
        if sections.count == 0 {
            noClassesToday()
            return
        }
        
        if sections.count >= 1 {
            
            hideLabels() // first hide everything
            
            self.class1Label.isHidden = false
            self.class1Label.text = getTextFromSection(section: sections[0])
        }
        
        if sections.count >= 2 {
            self.class2Label.isHidden = false
            self.class2Label.text = getTextFromSection(section: sections[1])
        }
        
        if sections.count >= 3 {
            self.class3Label.isHidden = false
            self.class3Label.text = getTextFromSection(section: sections[2])
        }
        
        if sections.count >= 4 {
            self.class4Label.isHidden = false
            self.class4Label.text = getTextFromSection(section: sections[3])
        }
        
        if sections.count >= 5 {
            self.class5Label.isHidden = false
            self.class5Label.text = getTextFromSection(section: sections[4])
        }
        
        if sections.count >= 6 {
            self.class6Label.isHidden = false
            self.class6Label.text = getTextFromSection(section: sections[5])
        }
        
        if sections.count >= 7 {
            self.class7Label.isHidden = false
            self.class7Label.text = getTextFromSection(section: sections[6])
        }
    }
    
    func getTextFromSection(section: Section) -> String {
        
        let paddedStr = section.note.padding(toLength: 10, withPad: " ", startingAt: 0)
        
        return "📚\(paddedStr) 🕗\(section.timing[0].timeFrom)-\(section.timing[0].timeTo) \t🏫\(section.timing[0].room)"
    }

    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if (activeDisplayMode == NCWidgetDisplayMode.compact) {
            self.preferredContentSize = maxSize
        }
        else {
            self.preferredContentSize = CGSize(width: maxSize.width, height: 176)
        }
    }

    func widgetPerformUpdate(_ completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
                
        completionHandler(NCUpdateResult.newData)
    }
    
}

extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: Date()).capitalized
        // or use capitalized(with: locale) if you want
    }
}

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}



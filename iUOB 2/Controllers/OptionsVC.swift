//
//  OptionsVC.swift
//  iUOB 2
//
//  Created by Miqdad Altaitoon on 12/17/16.
//  Copyright © 2016 Miqdad Altaitoon. All rights reserved.
//

import UIKit
import Alamofire
import Kanna
import MBProgressHUD
import NYAlertViewController

class OptionsVC: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var totalCombinationsLabel: UILabel!
    @IBOutlet weak var tooMuchLabel: UILabel!
    @IBOutlet weak var workingDaysSegmentedControl: UISegmentedControl!
    @IBOutlet weak var startAtSegmentedControl: UISegmentedControl!
    @IBOutlet weak var finishAtSegmentedControl: UISegmentedControl!
    @IBOutlet weak var lecturesLocationsSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var filterChangedImageView: UIImageView!
    @IBOutlet weak var sectionsFilterOutlet: UIButton!
    
    @IBOutlet weak var nextButtonOutlet: UIBarButtonItem!
    
    var addedCourses: [String] = []    // added courses
    var semester: Int = 0
    
    var courseSectionDict = [String: [Section]]()   // source of all sctions
    var filteredCourseSectionDict = [String: [Section]]()   // courseSectionDict after applaying filters
    
    var filterChanged = false   // if user used filter at last or not

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButtonOutlet.isEnabled = false
        filterChangedImageView.isHidden = true
        tooMuchLabel.text = ""
        
        disableAll()
        
        sectionsFilterOutlet.layer.cornerRadius = 15
        
        getDepartments()
        
        googleAnalytics()
    }
    
    func googleAnalytics() {
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: NSStringFromClass(type(of: self)).components(separatedBy: ".").last!)
            let builder: NSObject = GAIDictionaryBuilder.createScreenView().build()
            tracker.send(builder as! [NSObject : AnyObject])
        }
    }
    
    func disableAll() {
        workingDaysSegmentedControl.isEnabled = false
        startAtSegmentedControl.isEnabled = false
        finishAtSegmentedControl.isEnabled = false
        lecturesLocationsSegmentedControl.isEnabled = false
        sectionsFilterOutlet.isEnabled = false
        
        totalCombinationsLabel.text = "0"
    }
    
    func enableAll() {
        workingDaysSegmentedControl.isEnabled = true
        startAtSegmentedControl.isEnabled = true
        finishAtSegmentedControl.isEnabled = true
        lecturesLocationsSegmentedControl.isEnabled = true
        sectionsFilterOutlet.isEnabled = true
    }

    func getDepartments() {
        
        let url = "\(Constants.baseURL)/cgi/enr/schedule2.abrv"
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        Alamofire.request(url, method: .get, parameters: ["prog": "1", "cyer": "2016", "csms": semester])
            .validate()
            .responseString { response in
                
                MBProgressHUD.hide(for: self.view, animated: true)
                
                if response.result.error == nil {
                    
                    let departments = UOBParser.parseDepartments(response.result.value!)
                    
                    if departments.count == 0 {
                        
                        self.showAlert(title: "Sorry", msg: "Schedule for 2016\\\(self.semester) is not available. Make sure you select the right semester.")
                    } else {
                        self.getNextCourseData(0) // get first course
                    }
                    
                } else {
                    
                    self.showAlert(title: "Error", msg: (response.result.error?.localizedDescription)!)

                }
        }
    }
    
    
    func getNextCourseData(_ index: Int) {
        
        let thisCourse = addedCourses[index]
        let seperate = thisCourse.index(thisCourse.endIndex, offsetBy: -3)  // last three characters represent the courseNo e.g 101 in ITCS101
        
        let courseNo = thisCourse.substring(from: seperate)
        let department = thisCourse.substring(to: seperate)
        var departmentCode = ""
        
        if let dCode = Constants.depCodeMapping[department] {
            departmentCode = dCode
        }
        
        let url = "\(Constants.baseURL)/cgi/enr/schedule2.contentpage"
        
        Alamofire.request(url, parameters: ["abv": department, "inl": "\(departmentCode)", "crsno": "\(courseNo)", "prog": "1", "crd": "3", "cyer": "2016", "csms": semester])
            .validate()
            .responseString { response in
                
                if response.result.error == nil {
                    self.parseResult(html: response.result.value!, index: index, course: thisCourse)
                } else {
                    
                    self.showAlert(title: "Error", msg: (response.result.error?.localizedDescription)!)
                }
        }
    }
    
    func parseResult(html: String, index: Int, course: String) {
        
        var allSections = [Section]()
        
        for section in UOBParser.parseSections(html) {
            
            if section.timing.count > 0 {   // if it has a time (some sections come without time e.g for COE)
                
                var sec = section
                sec.note = course
                
                allSections.append(sec)
            }
        }
        
        if allSections.count > 0 {
            courseSectionDict[course] = allSections // update dictinary
        } else {
            showAlert(title: "Course not found", msg: "Course [\(course)] not found")
        }
        
        // load others recuresvly
        if index + 1 < self.addedCourses.count {
            self.getNextCourseData(index + 1)
        } else {
            
            self.checkForFinalExamClashes()
            self.createTimeTable()
            self.updatePossibleCombinations()
        }
    }
    
    func checkForFinalExamClashes() {
        
        let lazyMapCollection = courseSectionDict.keys
        let keysArray = Array(lazyMapCollection.map { String($0)! })

        for i in 0..<keysArray.count {
            for j in i+1..<keysArray.count {
                
                let courseA = courseSectionDict[keysArray[i]]!.last!
                let courseB = courseSectionDict[keysArray[j]]!.last!
                
                if let finalDateA = courseA.finalExam.date, let finalDateB = courseB.finalExam.date {
                    if finalDateA == finalDateB {
                        if courseA.finalExam.startTime == courseB.finalExam.startTime {
                            // clash
                            self.showAlert(title: "Final exam clash", msg: "There is a clash in the final exam between \(keysArray[i]) and \(keysArray[j])")
                        }
                    }
                }
            }
        }
    }
    
    func createTimeTable() {
        
        filteredCourseSectionDict = courseSectionDict
    }
    
    @IBAction func segmetChangeEvent(_ sender: UISegmentedControl) {
        
        if filterChanged {
            
            filterChanged = false
            self.filterChangedImageView.isHidden = true
            
            showAlert(title: "Reset", msg: "Filter has beed reset. Please use [Sections Filter] at last")
        }
        
        filteredCourseSectionDict = [:] // reset filtered
        
        for (course, sections) in courseSectionDict {
            
            filteredCourseSectionDict[course] = []
            for section in sections {

                var passSection = false
                
                for timing in section.timing {
                    
                    if workingDaysSegmentedControl.selectedSegmentIndex > 0 {
                        
                        let workingDays = workingDaysSegmentedControl.titleForSegment(at: workingDaysSegmentedControl.selectedSegmentIndex)!
                        
                        for day in timing.day.characters {
                            
                            if (workingDays.range(of: "\(day)") == nil) {
                                
                                passSection = true // the section contain a day not in the user's selected working days
                                break
                            }
                        }
                        
                        if passSection {break} // go for next section
                    }
                    
                    if startAtSegmentedControl.selectedSegmentIndex > 0 {
                        
                        let startTime = startAtSegmentedControl.selectedSegmentIndex + 8 // 9,10,11,12
                        
                        let timeArr = timing.timeFrom.components(separatedBy: ":")
                        
                        if timeArr.count > 1 {
                            
                            let sectionStartTime = Float(Float(timeArr[0])! + (Float(timeArr[1])! / 60.0))
                            
                            if Float(startTime) > sectionStartTime {
                                passSection = true
                                break
                            }
                        }
                    }
                    
                    if finishAtSegmentedControl.selectedSegmentIndex > 0 {
                        
                        let finishTime = finishAtSegmentedControl.selectedSegmentIndex + 11 // 12,1,2,3
                        
                        let timeArr = timing.timeTo.components(separatedBy: ":")
                        
                        if timeArr.count > 1 {
                            
                            let sectionFinishTime = Float(Float(timeArr[0])! + (Float(timeArr[1])! / 60.0))
                            
                            if Float(finishTime) < sectionFinishTime {
                                
                                passSection = true
                                break
                            }
                        }
                    }
                    
                    if lecturesLocationsSegmentedControl.selectedSegmentIndex > 0 {
                        
                        let room = timing.room
                        var location = 0    // 0 = Sakheer, 1 = Isa Town
                        
                        if room.characters.count > 1 {
                            
                            if room.range(of: "-") != nil {
                                
                                let roomArr = room.components(separatedBy: "-")
                                
                                if let number = Int(roomArr[0]) {
                                    
                                    if number > 0 && number < 38 {
                                        location = 1
                                    }
                                } else if roomArr[0] == "A27" {
                                    location = 1
                                }
                            }
                        }
                        
                        if lecturesLocationsSegmentedControl.selectedSegmentIndex == 1 && location != 0 {
                            passSection = true
                            break

                        } else if lecturesLocationsSegmentedControl.selectedSegmentIndex == 2 && location != 1 {
                            passSection = true
                            break
                        }
                    }
                }
                
                if passSection {
                    continue
                } else {
                    filteredCourseSectionDict[course]?.append(section)
                }
                
            }
        }
        
        updatePossibleCombinations()
    }
    
    
    func updatePossibleCombinations() {
        
        var totalCombinations = 1
        
        for (_, sections) in filteredCourseSectionDict {
            
            totalCombinations *= sections.count
        }
        
        totalCombinationsLabel.text = "\(totalCombinations)"
        
        enableAll()
        
        if totalCombinations > 0 && totalCombinations < 20000 {
            nextButtonOutlet.isEnabled = true
        } else {
            nextButtonOutlet.isEnabled = false
        }
        
        if totalCombinations > 20000 {
            tooMuchLabel.text = "should be less than 20000"
        } else {
            tooMuchLabel.text = ""
        }
    }
    
    @IBAction func combinationsInfoButton(_ sender: Any) {
        
        showAlert(title: "Info", msg: "Number of possible combinations is the number of MAXIMUM possible combinations for the courses you entered. It should be less than 20000 in order to continue to the next page which will show you the TRUE number of combinations. You can minimize the number of possible combinations by selecting different options below.")
    }
    
    @IBAction func filterInfoButton(_ sender: Any) {
        
       // Filter has beed reset. Please use [Sections Filter] at last
        
        showAlert(title: "Info", msg: "Use [Section Filter] for extra options. You can choose what section you want to be included individually. Please use [Section Filter] after selecting the Working Days/Times/Location.")

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

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SectionsFilterSegue" {

            let destinationNavigationController = segue.destination as! UINavigationController
            let nextScene = destinationNavigationController.topViewController as? SectionsFilterVC
            
            nextScene!.courseSectionDict = courseSectionDict
            nextScene!.filteredCourseSectionDict = filteredCourseSectionDict
        } else if segue.identifier == "SummarySegue" {
            
            let nextScene = segue.destination as? SummaryVC
            
            nextScene!.filteredCourseSectionDict = filteredCourseSectionDict
        }        
    }
    
    @IBAction func unwindToOptionsVC(segue: UIStoryboardSegue) {
        
        if let sectionsFilterVC = segue.source as? SectionsFilterVC {
            
            self.filteredCourseSectionDict = sectionsFilterVC.filteredCourseSectionDict
            self.filterChanged = sectionsFilterVC.filterChanged
            
            if self.filterChanged {
                self.filterChangedImageView.isHidden = false
            } else {
                self.filterChangedImageView.isHidden = true
            }
            
            updatePossibleCombinations()
        }
    }
}

//
//  MyScheduleVC.swift
//  iUOB 2
//
//  Created by Miqdad Altaitoon on 9/26/16.
//  Copyright © 2016 Miqdad Altaitoon. All rights reserved.
//

import UIKit
import Alamofire
import Kanna
import MBProgressHUD
import NYAlertViewController

class MyScheduleVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: - Properties
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var courses: [String] = []
    var sections: [String] = []
    var mySections: [Section] = []  // user choosen sections
    var cvSections: [Section] = []  // to appear on the collection view
    
    let refresher = UIRefreshControl()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleAnalytics()
        
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        
        self.collectionView!.alwaysBounceVertical = true
        refresher.tintColor = UIColor.black
        refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        collectionView!.addSubview(refresher)
    }
    
    func googleAnalytics() {
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: NSStringFromClass(type(of: self)).components(separatedBy: ".").last!)
            let builder: NSObject = GAIDictionaryBuilder.createScreenView().build()
            tracker.send(builder as! [NSObject : AnyObject])
        }
    }
    
    func loadData() {
        
        if courses.count > 0 {
            
            mySections = []
            cvSections = []

            getNextCourseData(0, cache: false) // get without caching
        } else {
            stopRefresher()
        }
    }
    
    func stopRefresher() {
        refresher.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mySections = []
        cvSections = []

        let data = Constants.getCoursesAndSections()
        
        courses = data.courses
        sections = data.sections
        
        
        if courses.count > 0 {
            getNextCourseData(0, cache: true) // get first course
        } else {
            self.collectionView.reloadData()
        }
    }

    func getNextCourseData(_ index: Int, cache: Bool) {
        
        let thisCourse = self.courses[index]
        let seperate = thisCourse.index(thisCourse.endIndex, offsetBy: -3)  // last three characters represent the courseNo e.g 101 in ITCS101
        
        let courseNo = thisCourse.substring(from: seperate)
        let department = thisCourse.substring(to: seperate)
        var departmentCode = ""
        
        let url = "\(Constants.baseURL)/cgi/enr/schedule2.contentpage"
        
        if let dCode = Constants.depCodeMapping[department] {
            departmentCode = dCode
        } else {
            
            // skip this couse it is not a valid course
            if index + 1 < self.courses.count {
                self.getNextCourseData(index + 1, cache: cache)
            } else {
                // done
                self.createTimeTable()
            }
        }
        
        var getLiveVersion = true  // in case there is no cache
        
        if cache {
            // try getting html from user default first
            
            let defaults: UserDefaults = UserDefaults(suiteName: "group.com.muqdd.iuob")!
            if let rawHTML = defaults.object(forKey: "\(self.courses[index])-\(self.sections[index])") as? String {
                
                getLiveVersion = false
                self.parseResult(html: rawHTML, index: index, cache: cache, course: thisCourse)
            }
        }
        
        if !getLiveVersion {
            return
        }
        
        Alamofire.request(url, parameters: ["abv": department, "inl": "\(departmentCode)", "crsno": "\(courseNo)", "prog": "1", "crd": "3", "cyer": "2016", "csms": "2"])
            .validate()
            .responseString { response in
                
                if response.result.error == nil {
                    
                    let defaults: UserDefaults = UserDefaults(suiteName: "group.com.muqdd.iuob")!
                    defaults.set(response.result.value!, forKey: "\(self.courses[index])-\(self.sections[index])")
                    defaults.synchronize()
                    
                    self.parseResult(html: response.result.value!, index: index, cache: cache, course: thisCourse)
                }
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
        
        stopRefresher()
        
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

        let counts = [sundays.count, mondays.count, tuesdays.count, wednesdays.count, thursdays.count]
        
        let emptySlot = Section.init(sectionNo: "", doctor: "", seats: "", timing: [Timing.init(day: "", timeFrom: "", timeTo: "", room: "")], note: "", finalExam: FinalExam.init(date: nil, startTime: "", endTime: ""))  // for collectionview cells that have no data
        
        for i in 0..<counts.max()! {
            
            if i < sundays.count {
                self.cvSections.append(sundays[i])
            } else {
                self.cvSections.append(emptySlot)
            }
            
            if i < mondays.count {
                self.cvSections.append(mondays[i])
            } else {
                self.cvSections.append(emptySlot)
            }
            
            if i < tuesdays.count {
                self.cvSections.append(tuesdays[i])
            } else {
                self.cvSections.append(emptySlot)
            }
            
            if i < wednesdays.count {
                self.cvSections.append(wednesdays[i])
            } else {
                self.cvSections.append(emptySlot)
            }
            
            if i < thursdays.count {
                self.cvSections.append(thursdays[i])
            } else {
                self.cvSections.append(emptySlot)
            }
        }

        self.collectionView.reloadData()
    }

    
    // MARK: - UICollectionViewDataSource protocol
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return cvSections.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let courseCell = collectionView.dequeueReusableCell(withReuseIdentifier: "courseCell", for: indexPath) as! CourseCVCell
        
        let section = self.cvSections[indexPath.item]
        
        if section.sectionNo.characters.count > 0 {
            courseCell.courseTitleLabel.text = section.note
            courseCell.startTimeLabel.text = section.timing[0].timeFrom
            courseCell.endTimeLabel.text = section.timing[0].timeTo
            courseCell.locationLabel.text = section.timing[0].room
            
            courseCell.backgroundColor = backgroaundColor(forCourse: section.note)

        } else {
            courseCell.courseTitleLabel.text = ""
            courseCell.startTimeLabel.text = ""
            courseCell.endTimeLabel.text = ""
            courseCell.locationLabel.text = ""

            courseCell.backgroundColor = UIColor.clear
        }
        
        return courseCell
    }
    
    func backgroaundColor(forCourse course: String) -> UIColor {
        
        let seperate = course.index(course.endIndex, offsetBy: -3)
        let courseNo = course.substring(from: seperate)             // 346
        let department = course.substring(to: seperate)             // ITCS
        
        var rand = 0    // random number to generate the color
        
        /* first: we generate a number based on the department */
        for x in department.asciiArray {
            
            if x % 2 == 0 {
                rand += Int(x * x)
            } else {
                rand += Int(x * 13)
            }
        }
        
        /* seconds: we make adjustment based on the course number so courses from same department have the same color but with a slight hue adjustment */
        let courseNumberAdjusment = CGFloat(Double((Int(courseNo)! * Int(courseNo)! * 13) % 15) / 100.0)
        
        let hue = CGFloat(Double((rand % 256)) / 256.0) + courseNumberAdjusment
        
        return UIColor(hue: hue, saturation: 0.7, brightness: 0.8, alpha: 0.3)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        
        case UICollectionElementKindSectionHeader:
            
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: "CVHeader",
                                                                             for: indexPath) as! CoursesCVHeader
            headerView.uLabel.text = "U"
            headerView.mLabel.text = "M"
            headerView.tLabel.text = "T"
            headerView.wLabel.text = "W"
            headerView.hLabel.text = "H"
            
        
            return headerView
        default:
            
            fatalError("Unexpected element kind")
        }
    }
    
    // MARK: - UICollectionViewDelegate protocol
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let section = self.cvSections[indexPath.item]
        
        if section.sectionNo.characters.count <= 0 {
            return
        }
        
        let alertViewController = NYAlertViewController()
        
        alertViewController.title = section.note
        
        var finalText = ""
        if let finalDate = section.finalExam.date {
            finalText = "\(finalDate.formattedLong) @\(section.finalExam.startTime)-\(section.finalExam.endTime)"
            
        } else {
            finalText = "No Exam"
        }
        
        alertViewController.message = "Section: \(section.sectionNo)\nDoctor: \(section.doctor)\nFinal: \(finalText)"
        
        alertViewController.buttonCornerRadius = 20.0
        alertViewController.view.tintColor = self.view.tintColor
        
        alertViewController.cancelButtonColor = UIColor(netHex:0xFFA739)
        
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
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let cellSize:CGSize = CGSize(width: collectionView.frame.width / 5 - 1, height: 84)
        
        return cellSize
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }

        flowLayout.itemSize = CGSize(width: self.view.bounds.size.width / 5 - 1, height: 84)
        
        flowLayout.invalidateLayout()
        
        self.collectionView.reloadData()
    }

}

extension String {
    var asciiArray: [UInt32] {
        return unicodeScalars.filter{$0.isASCII}.map{$0.value}
    }
}




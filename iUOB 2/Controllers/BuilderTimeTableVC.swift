//
//  BuilderTimeTableVC.swift
//  iUOB 2
//
//  Created by Miqdad Altaitoon on 1/16/17.
//  Copyright © 2017 Miqdad Altaitoon. All rights reserved.
//

import UIKit
import Alamofire
import Kanna
import MBProgressHUD
import NYAlertViewController

class BuilderTimeTableVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var mySections = [Section]()  // user choosen sections
    var cvSections: [Section] = []  // to appear on the collection view
    
    // here, some formatting
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleAnalytics()
        
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        
        createTimeTable()
    }
    
    func googleAnalytics() {
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: NSStringFromClass(type(of: self)).components(separatedBy: ".").last!)
            let builder: NSObject = GAIDictionaryBuilder.createScreenView().build()
            tracker.send(builder as! [NSObject : AnyObject])
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
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "ScheduleDetailsSegue" {
            
            let destinationNavigationController = segue.destination as! UINavigationController
            let nextScene = destinationNavigationController.topViewController as? ScheduleDetailsVC
            
            nextScene!.sections = mySections
        }
    }
    
}





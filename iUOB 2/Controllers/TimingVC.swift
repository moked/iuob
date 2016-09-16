//
//  TimingVC.swift
//  iUOB 2
//
//  Created by Miqdad Altaitoon on 8/11/16.
//  Copyright © 2016 Miqdad Altaitoon. All rights reserved.
//

import UIKit
import Alamofire
import Kanna
import MBProgressHUD

class TimingVC: UITableViewController {
    
    // MARK: - Properties
    
    var course: Course!
    var sections: [Section] = []

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleAnalytics()
        
        self.title = course.code
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 132
        
        getSections()
    }

    func googleAnalytics() {
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!)
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    /* function to set coustom view in nav bar title */
    func setTitle(title:String, subtitle:String) -> UIView {
        let titleLabel = UILabel(frame: CGRectMake(0, -2, 0, 0))
        
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.font = UIFont.boldSystemFontOfSize(17)
        titleLabel.text = title
        titleLabel.sizeToFit()
        
        let subtitleLabel = UILabel(frame: CGRectMake(0, 18, 0, 0))
        subtitleLabel.backgroundColor = UIColor.clearColor()
        subtitleLabel.textColor = UIColor.redColor()
        subtitleLabel.font = UIFont.boldSystemFontOfSize(12)
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()
        
        let titleView = UIView(frame: CGRectMake(0, 0, max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), 30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
        
        if widthDiff > 0 {
            var frame = titleLabel.frame
            frame.origin.x = widthDiff / 2
            titleLabel.frame = CGRectIntegral(frame)
        } else {
            var frame = subtitleLabel.frame
            frame.origin.x = abs(widthDiff) / 2
            titleLabel.frame = CGRectIntegral(frame)
        }
        
        return titleView
    }
    
    // MARK: - Load Data
    
    func getSections() {
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        Alamofire.request(.GET, course.url, parameters: nil)
            .validate()
            .responseString { response in
                
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
                if response.result.error == nil {

                    self.sections = UOBParser.parseSections(response.result.value!)
                    
                    if self.sections.count > 0 {
                        
                        if let section = self.sections.last {
                            
                            if let finalDate = section.finalExam.date {
                                let finalExam = "Final: \(finalDate.formattedLong) @\(section.finalExam.startTime)-\(section.finalExam.endTime)"

                                self.navigationItem.titleView = self.setTitle(self.course.code, subtitle: finalExam)
                                
                            } else {
                                self.navigationItem.titleView = self.setTitle(self.course.code, subtitle: "Final: No Exam")

                            }
                        }
                    }
                    
                    self.getSeats()
                    
                    self.tableView.reloadData()
                } else {
                    print("error man")
                }
        }
    }

    
    func getSeats() {
        
        let seatsURL = "\(Constants.baseURL)/cgi/enr/enr_sections?pcrsnbr=\(course.courseNo)&pcrsinlcde=\(course.departmentCode)&course_desp=MOKED"
        
        Alamofire.request(.GET, seatsURL, parameters: nil)
            .validate()
            .responseString { response in
                
                if response.result.error == nil {
                    
                    UOBParser.parseSeats(response.result.value!, sections: &self.sections)
                
                    self.tableView.reloadData()
                } else {
                    print("error man")
                }
        }
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TimeCell", forIndexPath: indexPath) as! TiimingCell
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        
        let section = sections[indexPath.row]
        
        cell.sectionNoLabel.text = section.sectionNo
        cell.doctorNameLabel.text = section.doctor
        cell.seatsLabel.text = section.seats
        
        var days = ""
        var times = ""
        var rooms = ""
        
        var isFirstLine = true
        for time in section.timing {
            
            if isFirstLine {
                days = "\(time.day)"
                times = "\(time.timeFrom)-\(time.timeTo)"
                rooms = "\(time.room)"
                
                isFirstLine = false
            } else {
                days = "\(days)\n\(time.day)"
                times = "\(times)\n\(time.timeFrom)-\(time.timeTo)"
                rooms = "\(rooms)\n\(time.room)"
            }
        }
        
        cell.dayLabel.text = days
        cell.timeLabel.text = times
        cell.roomLabel.text = rooms
        
        cell.watchButton.tag = indexPath.row
        cell.watchButton.addTarget(self, action: #selector(TimingVC.watchPressed(_:)), forControlEvents: .TouchUpInside)

        return cell
    }
    
    func watchPressed(sender: UIButton!) {
        // code for monitoring courses [for UOB Auto]
    }
}

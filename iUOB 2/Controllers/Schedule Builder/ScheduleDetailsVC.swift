//
//  ScheduleDetailsVC.swift
//  iUOB 2
//
//  Created by Miqdad Altaitoon on 1/16/17.
//  Copyright © 2017 Miqdad Altaitoon. All rights reserved.
//

import UIKit


/// details of the option + ability to share
class ScheduleDetailsVC: UIViewController {

    var sections = [Section]()  // user choosen sections

    @IBOutlet weak var detailsTextView: UITextView!
    
    var summaryText = ""

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        googleAnalytics()
        
        buildSummary()
    }
    
    func googleAnalytics() {
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: NSStringFromClass(type(of: self)).components(separatedBy: ".").last!)
            let builder: NSObject = GAIDictionaryBuilder.createScreenView().build()
            tracker.send(builder as! [NSObject : AnyObject])
        }
    }

    
    func buildSummary() {
        
        for section in sections {
            
            summaryText += "Course: \(section.note)\nSection #: \(section.sectionNo)\nDoctor: \(section.doctor)\n"
            
            if let finalDate = section.finalExam.date {
                summaryText += "Final Exam: \(finalDate.formattedLong) @\(section.finalExam.startTime)-\(section.finalExam.endTime)\n"
            } else {
                summaryText += "Final Exam: No Exam\n"
            }
            
            summaryText += "Time: "
            
            for timing in section.timing {
                
                summaryText += "\(timing.day) [\(timing.timeFrom)-\(timing.timeTo)] in [\(timing.room)]\n"
            }
            
            summaryText += "-------------------------------\n"
            
        }
        
        self.detailsTextView.text = summaryText
    }

    @IBAction func actionShareButton(_ sender: Any) {
        
        // text to share
        let text = summaryText
        
        // set up activity view controller
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        //activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }

    @IBAction func doneButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


}

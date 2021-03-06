//
//  SummaryVC.swift
//  iUOB 2
//
//  Created by Miqdad Altaitoon on 12/19/16.
//  Copyright © 2016 Miqdad Altaitoon. All rights reserved.
//

import UIKit
import NYAlertViewController
import MBProgressHUD


/// all magic here. find the true number of combinations between the courses
class SummaryVC: UIViewController {

    // MARK: - Properties
    
    var filteredCourseSectionDict = [String: [Section]]()
    
    var sectionCombination = [[Section]]()  /// all sections

    @IBOutlet weak var schedulesFoundLabel: UILabel!
    @IBOutlet weak var nextButtonOutlet: UIBarButtonItem!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nextButtonOutlet.isEnabled = false
        
        builderAlgorithm()
        
        googleAnalytics()
    }
    
    func googleAnalytics() {
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: NSStringFromClass(type(of: self)).components(separatedBy: ".").last!)
            let builder: NSObject = GAIDictionaryBuilder.createScreenView().build()
            tracker.send(builder as! [NSObject : AnyObject])
        }
    }

    /**
     this function do everything, but it should be refactored for more efficencey + readablilty
     
     example of what this algorithm do:
     let say we have 3 courses which have 3, 2, 5 section respectivly:
     
     course [0]: [0][1][2]
     course [1]: [0][1]
     course [2]: [0][1][2][3][4]
     
     we will have (3 * 2 * 5 = 30) possible combinations between them.
     so insted of going through all sections recuresvly, I refactured the recurseve function into an iteration loop which is much faster.
     in order to do it, we need 2 arrays. On to store the current indeces that we have. And the other one to store the actual size for each of the sections array.
     
     It will go like this:
     comb 1: [0][0][0]
     comb 2: [0][0][1]
     comb 3: [0][0][2]
     ...
     comb 30: [2][1][4]

     */
    func builderAlgorithm() {
        
        self.schedulesFoundLabel.text = "Calculating..."
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        DispatchQueue.global(qos: .background).async {  // do calucaltion in background thread
            
            var allCombinationCount = 1 // all possible combination to iterate through
            var indicesArray:[Int] = [] // array to store current indeces for each of the course' sections
            var indicesSizeArray:[Int] = [] // array to store the true size for each of the course' sections
            
            let lazyMapCollection = self.filteredCourseSectionDict.keys
            let keysArray = Array(lazyMapCollection.map { String($0)! })
            
            /* initilaizing arrays */
            for i in 0..<keysArray.count {
                
                allCombinationCount *= self.filteredCourseSectionDict[keysArray[i]]!.count
                indicesArray.append(0) // init. zero index for all courses/sections
                indicesSizeArray.append(self.filteredCourseSectionDict[keysArray[i]]!.count) // init sizes
            }
            
            /* go through all possible combinations */
            for _ in 0..<allCombinationCount {
                
                var sectionsToCompare: [Section] = []   // reset each time
                
                for j in 0..<keysArray.count {
                    
                    sectionsToCompare.append(self.filteredCourseSectionDict[keysArray[j]]![indicesArray[j]])
                }
                
                // compare sectionsToCompare, if no clashes, add to new array. to find clshes, double for loop
                
                var isSectionClash = false
                
                for i in 0..<sectionsToCompare.count-1 {
                    
                    if isSectionClash {break}
                    
                    for j in i+1..<sectionsToCompare.count {
                        
                        if isSectionClash {break}
                        
                        let sectionA = sectionsToCompare[i]
                        let sectionB = sectionsToCompare[j]
                        
                        /* compare section A and B. if same day & same cross in time -> CLASH */
                        
                        for timingA in sectionA.timing {
                            
                            for timingB in sectionB.timing {
                                
                                for dayA in timingA.day.characters {
                                    
                                    for dayB in timingB.day.characters {
                                        
                                        if dayA == dayB {
                                            // if same day -> check timing
                                            
                                            let timeStartArrA = timingA.timeFrom.components(separatedBy: ":")
                                            let timeStartArrB = timingB.timeFrom.components(separatedBy: ":")
                                            
                                            let timeEndArrA = timingA.timeTo.components(separatedBy: ":")
                                            let timeEndArrB = timingB.timeTo.components(separatedBy: ":")
                                            
                                            if timeStartArrA.count > 1 && timeStartArrB.count > 1 && timeEndArrA.count > 1 && timeEndArrB.count > 1 {
                                                
                                                let sectionAStartTime = Float(Float(timeStartArrA[0])! + (Float(timeStartArrA[1])! / 60.0))
                                                let sectionBStartTime = Float(Float(timeStartArrB[0])! + (Float(timeStartArrB[1])! / 60.0))
                                                
                                                let sectionAEndTime = Float(Float(timeEndArrA[0])! + (Float(timeEndArrA[1])! / 60.0))
                                                let sectionBEndTime = Float(Float(timeEndArrB[0])! + (Float(timeEndArrB[1])! / 60.0))
                                                
                                                if (sectionAStartTime >= sectionBStartTime && sectionAStartTime <= sectionBEndTime) ||
                                                    (sectionAEndTime >= sectionBStartTime && sectionAEndTime <= sectionBEndTime) ||
                                                    (sectionBStartTime >= sectionAStartTime && sectionBStartTime <= sectionAEndTime) ||
                                                    (sectionBEndTime >= sectionAStartTime && sectionBEndTime <= sectionAEndTime) {
                                                    
                                                    // if start or end time is between other lectures times -> CLASH
                                                    
                                                    isSectionClash = true
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                if !isSectionClash {
                    
                    self.sectionCombination.append(sectionsToCompare)
                }
                
                /* state machine to determin each index of arrays */
                for index in 0..<self.filteredCourseSectionDict.count {
                    
                    if indicesArray[index] + 1 == indicesSizeArray[index] {
                        
                        indicesArray[index] = 0 // reset
                        
                    } else {
                        indicesArray[index] += 1  // increment current index
                        break
                    }
                }
            }

            
            DispatchQueue.main.async {
                
                MBProgressHUD.hide(for: self.view, animated: true)
                
                self.schedulesFoundLabel.text = "\(self.sectionCombination.count)"
                
                if self.sectionCombination.count == 0 {
                    
                    self.nextButtonOutlet.isEnabled = false
                    
                    self.showAlert(title: "Not found", msg: "No schedule found. Please go back and choose other options or other courses")
                    
                } else {
                    self.nextButtonOutlet.isEnabled = true
                }
            }
        }
        
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
        if segue.identifier == "OptionsListSegue" {
            
            let nextScene = segue.destination as? OptionsListVC
            nextScene!.sectionCombination = sectionCombination
        }
    }
}

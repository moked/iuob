//
//  ScheduleBuilderVC.swift
//  iUOB 2
//
//  Created by Miqdad Altaitoon on 9/13/16.
//  Copyright © 2016 Miqdad Altaitoon. All rights reserved.
//

import UIKit

/* COMMING LATER */

class ScheduleBuilderVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleAnalytics()
    }

    func googleAnalytics() {
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!)
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
}

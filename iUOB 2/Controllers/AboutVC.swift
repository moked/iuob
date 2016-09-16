//
//  AboutVC.swift
//  iUOB 2
//
//  Created by Miqdad Altaitoon on 9/14/16.
//  Copyright © 2016 Miqdad Altaitoon. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class AboutVC: UIViewController, MFMailComposeViewControllerDelegate {

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
    
    @IBAction func gitHubButton(sender: AnyObject) {
        
        UIApplication.sharedApplication().openURL(NSURL(string: "https://github.com/moked/iuob")!)
    }

    @IBAction func emailButton(sender: AnyObject) {
        
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients(["muqdd@hotmail.com"])
        composeVC.setSubject("iUOB 2")
        
        self.presentViewController(composeVC, animated: true, completion: nil)
    }
    
    @IBAction func twitterButton(sender: AnyObject) {
        
        let handle =  "muqdd"
        let appURL = NSURL(string: "twitter://user?screen_name=\(handle)")!
        let webURL = NSURL(string: "https://twitter.com/\(handle)")!
        
        let application = UIApplication.sharedApplication()
        
        if application.canOpenURL(appURL) {
            application.openURL(appURL)
        } else {
            application.openURL(webURL)
        }
    }

    @IBAction func webButton(sender: AnyObject) {
        
        UIApplication.sharedApplication().openURL(NSURL(string: "http://iuob.net")!)
    }
    
    func mailComposeController(controller: MFMailComposeViewController,
                               didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

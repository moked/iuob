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

    @IBOutlet weak var logoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoImageView.layer.cornerRadius = 16
        
        googleAnalytics()
    }
    
    func googleAnalytics() {
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: NSStringFromClass(type(of: self)).components(separatedBy: ".").last!)
            let builder: NSObject = GAIDictionaryBuilder.createScreenView().build()
            tracker.send(builder as! [NSObject : AnyObject])
        }
    }
    
    @IBAction func gitHubButton(_ sender: AnyObject) {
        
        UIApplication.shared.openURL(URL(string: "https://github.com/moked/iuob")!)
    }

    @IBAction func emailButton(_ sender: AnyObject) {
        
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients(["muqdd@hotmail.com"])
        composeVC.setSubject("iUOB 2")
        
        self.present(composeVC, animated: true, completion: nil)
    }
    
    @IBAction func twitterButton(_ sender: AnyObject) {
        
        let handle =  "muqdd"
        let appURL = URL(string: "twitter://user?screen_name=\(handle)")!
        let webURL = URL(string: "https://twitter.com/\(handle)")!
        
        let application = UIApplication.shared
        
        if application.canOpenURL(appURL) {
            application.openURL(appURL)
        } else {
            application.openURL(webURL)
        }
    }

    @IBAction func webButton(_ sender: AnyObject) {
        
        UIApplication.shared.openURL(URL(string: "http://muqdd.com")!)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

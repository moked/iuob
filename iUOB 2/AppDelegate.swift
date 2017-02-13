//
//  AppDelegate.swift
//  iUOB 2
//
//  Created by Miqdad Altaitoon on 8/8/16.
//  Copyright © 2016 Miqdad Altaitoon. All rights reserved.
//

import UIKit
import SideMenuController
import Firebase
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Configure tracker from GoogleService-Info.plist.
//        var configureError:NSError?
//        GGLContext.sharedInstance().configureWithError(&configureError)
//        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        let gai = GAI.sharedInstance()
        gai?.trackUncaughtExceptions = true  // report uncaught exceptions
        
        /* Firabase */
        FIRApp.configure()
        
        /* Google Maps */
        GMSServices.provideAPIKey("AIzaSyCK0kHb7PaGjK-u1sRqezcju0pGfhf9eKY")
        
        var isLaunchedFromQuickAction = false
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            
            isLaunchedFromQuickAction = true
            // Handle the sortcutItem
            let _ = handleQuickAction(shortcutItem: shortcutItem)
        }
        
        return !isLaunchedFromQuickAction
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        print("%@", userInfo)
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        // Handle quick actions
        
        completionHandler(handleQuickAction(shortcutItem: shortcutItem))
    }
    
    enum Shortcut: String {
        case Myschedule = "Myschedule"
        case Builder = "Builder"
        case Semesterschedule = "Semesterschedule"
        case Map = "Map"
    }
    
    func handleQuickAction(shortcutItem: UIApplicationShortcutItem) -> Bool {
        
        var quickActionHandled = false
        let type = shortcutItem.type.components(separatedBy: ".").last!
        let navigationController: CustomSideMenuController = (self.window!.rootViewController as! CustomSideMenuController)

        if let shortcutType = Shortcut.init(rawValue: type) {
            switch shortcutType {
            case .Myschedule:
                navigationController.performSegue(withIdentifier: "showStudentScheduleController", sender: nil)
                quickActionHandled = true
                
            case .Builder:
                navigationController.performSegue(withIdentifier: "showScheduleBuilderController", sender: nil)
                quickActionHandled = true

                
            case .Semesterschedule:
                navigationController.performSegue(withIdentifier: "showCenterController", sender: nil)
                quickActionHandled = true

            case .Map:
                navigationController.performSegue(withIdentifier: "showMapController", sender: nil)
                quickActionHandled = true
            }
            
        }
        
        return quickActionHandled
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}


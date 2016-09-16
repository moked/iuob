//
//  CustomSideMenuController.swift
//  iUOB 2
//
//  Created by Miqdad Altaitoon on 8/8/16.
//  Copyright © 2016 Miqdad Altaitoon. All rights reserved.
//

import UIKit
import SideMenuController

class CustomSideMenuController: SideMenuController {

    override func viewDidLoad() {
        super.viewDidLoad()
        performSegueWithIdentifier("showCenterController", sender: nil)
        performSegueWithIdentifier("containSideMenu", sender: nil)
    }
}

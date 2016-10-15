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
        performSegue(withIdentifier: "showCenterController", sender: nil)
        performSegue(withIdentifier: "containSideMenu", sender: nil)
    }
}

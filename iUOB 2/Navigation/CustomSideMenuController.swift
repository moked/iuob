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
    
    required init?(coder aDecoder: NSCoder) {
        
        SideMenuController.preferences.drawing.menuButtonImage = UIImage(named: "menu")
        SideMenuController.preferences.drawing.sidePanelPosition = .underCenterPanelLeft
        
        SideMenuController.preferences.drawing.sidePanelWidth = 300
        SideMenuController.preferences.drawing.centerPanelShadow = true
        
        SideMenuController.preferences.animating.statusBarBehaviour = .horizontalPan
        SideMenuController.preferences.animating.transitionAnimator = FadeAnimator.self
        
        super.init(coder: aDecoder)
    }
}

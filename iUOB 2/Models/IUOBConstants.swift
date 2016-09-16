//
//  IUOBConstants.swift
//  iUOB 2
//
//  Created by Miqdad Altaitoon on 9/13/16.
//  Copyright © 2016 Miqdad Altaitoon. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

struct Constants {
    
    static let baseURL = "https://www.online.uob.edu.bh"   // change for the domain you want e.g. uob :-]
    
    static let sakheerLocation = Location(latitude: 26.051588, longitude: 50.513387)
    static let isaTownLocation = Location(latitude: 26.165126, longitude: 50.545274)
}

struct Location {
    let latitude: Double
    let longitude: Double
}

struct IUOBMarkers {

    let position: CLLocationCoordinate2D
    let title: String
    let description: String
    let location: String    // sakheer or isa town
}

struct Link {
    
    init(name: String, url: String) {
        self.name = name
        self.url = url
    }
    
    var name: String = ""
    var url: String = ""
}
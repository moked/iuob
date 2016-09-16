//
//  Department.swift
//  iUOB 2
//
//  Created by Miqdad Altaitoon on 8/9/16.
//  Copyright © 2016 Miqdad Altaitoon. All rights reserved.
//

import Foundation

struct Department {
    
    init(name: String, url: String) {
        self.name = name
        self.url = url
    }
    
    var name: String = ""
    var url: String = ""
}
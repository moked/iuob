//
//  Course.swift
//  iUOB 2
//
//  Created by Miqdad Altaitoon on 8/10/16.
//  Copyright © 2016 Miqdad Altaitoon. All rights reserved.
//

import Foundation

struct Course {
    
    init(name: String, code: String, credits: String, preRequisite: String, url: String, abv: String, courseNo: String, departmentCode: String) {
        self.name = name
        self.code = code
        self.credits = credits
        self.preRequisite = preRequisite
        self.url = url
        
        self.abv = abv
        self.courseNo = courseNo
        self.departmentCode = departmentCode
    }
    
    var name: String = ""           // ANALYSIS AND DESIGN
    var code: String = ""           // ITCS346
    var credits: String = ""        // 3
    var preRequisite: String = ""   // ITCS215  ITCS253
    var url: String = ""            // ..prog=1&abv=ITCS&inl=222&crsno=346&crd=3&cyer=2016&csms=1
    
    var abv: String = ""            // ITCS
    var courseNo: String = ""       // 346
    var departmentCode: String = "" // 222
}
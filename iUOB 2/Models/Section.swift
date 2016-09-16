//
//  Section.swift
//  iUOB 2
//
//  Created by Miqdad Altaitoon on 8/12/16.
//  Copyright © 2016 Miqdad Altaitoon. All rights reserved.
//

import Foundation

struct Section {
    
    init(sectionNo: String, doctor: String, seats: String, timing: [Timing], note: String, finalExam: FinalExam) {
        self.sectionNo = sectionNo
        self.doctor = doctor
        self.seats = seats
        self.timing = timing
        self.note = note
        self.finalExam = finalExam
    }
    
    var sectionNo: String = ""      // 2
    var doctor: String = ""         // Dr. Ali Khan :(
    var seats: String = ""          // 3, 0, N/A
    var timing: [Timing] = []       // UTH 13:00-13:50 S40-2049
    var note: String = ""           // تدرس بمدينة عيسى
    var finalExam: FinalExam        // 22-01-2017 08:30 10:30
}

struct Timing {
    
    init(day: String, timeFrom: String, timeTo: String, room: String) {
        self.day = day
        self.timeFrom = timeFrom
        self.timeTo = timeTo
        self.room = room
    }
    
    var day = ""        // UTH
    var timeFrom = ""   // 13:00
    var timeTo = ""     // 13:50
    var room = ""       // S40-2049
}

struct FinalExam {
    
    init(date: NSDate?, startTime: String, endTime: String) {
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
    }
    
    var date: NSDate?   // optional couse some courses has no final exam
    var startTime = ""
    var endTime = ""
}


//
//  UOBParser.swift
//  iUOB 2
//
//  Created by Miqdad Altaitoon on 8/10/16.
//  Copyright © 2016 Miqdad Altaitoon. All rights reserved.
//

import Foundation
import Kanna

/******** class to parse html pages. their html is ugly as fuck. will add comments later ********/

class UOBParser {
    
    static func parseDepartments(_ html: String) -> [Department] {
        
        var departments: [Department] = []
        
        if let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8) {
            
            for link in doc.xpath("//a") {
                
                if let depName = link.text, let depURL = link["href"] {
                    departments.append(Department(name: depName, url: "\(Constants.baseURL)/cgi/enr/\(depURL)"))
                }
            }
        }
        
        return departments
    }
    
    static func parseCourses(_ html: String) -> [Course] {
        
        var courses = [Course]()
    
        var name: String = ""
        var code: String = ""
        var credits: String = ""
        let preRequisite: String = ""
        var url: String = ""
        
        var abv: String = ""
        var courseNo: String = ""
        var departmentCode: String = ""

        if let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8) {
            
            for link in doc.xpath("//a") {
                
                if let courseLink = link["href"] {
                    
                    if courseLink.hasPrefix("javascript:onclick") {
                        // pre requisite link
                        let macthes = matchesForRegexInText("\\(.*?\\)", text: courseLink)
                        
                        if macthes.count > 0 {
                            
                            var pre = macthes.first!.substring(to: macthes.first!.index(before:macthes.first!.endIndex))
                            pre = pre.substring(to: pre.index(before: pre.endIndex))
                            
                            
                            let index: String.Index = macthes.first!.index(macthes.first!.startIndex, offsetBy: 2)
                            
                            pre = pre.substring(to: pre.index(before: pre.endIndex))

                            pre = pre.substring(from: index)
                            
                            courses[courses.count-1].preRequisite = pre // assign pre to the last added course
                        }

                    } else {
                        
                        if let text = link.text {
                            
                            
                            // guard this code man, what the hell! hope it doesn't break :/
                            let index = text.characters.index(where: { $0 == " "})!
                            
                            code = text.substring(to: index)
                            
                            let indexEnd: String.Index = text.index(text.endIndex, offsetBy: -1)
                            
                            name = text.substring(to: indexEnd)
                            name = name.substring(from: name.index(index, offsetBy: 2)).capitalized
                            
                            url = "\(Constants.baseURL)/cgi/enr/\(courseLink)"
                            
                            let inl = matchesForRegexInText("inl=.*?&", text: courseLink)
                            departmentCode = inl.first!.substring(to: inl.first!.index(inl.first!.endIndex, offsetBy: -1))
                            departmentCode = departmentCode.substring(from: departmentCode.index(departmentCode.startIndex, offsetBy: 4))

                            
                            let abvvr = matchesForRegexInText("abv=.*?&", text: courseLink)
                            abv = abvvr.first!.substring(to: abvvr.first!.index(abvvr.first!.endIndex, offsetBy: -1))
                            abv = abv.substring(from: abv.index(abv.startIndex, offsetBy: 4))

                            let crsno = matchesForRegexInText("crsno=.*?&", text: courseLink)
                            courseNo = crsno.first!.substring(to: crsno.first!.index(crsno.first!.endIndex, offsetBy: -1))
                            courseNo = courseNo.substring(from: courseNo.index(courseNo.startIndex, offsetBy: 6))
                            
                            let crd = matchesForRegexInText("crd=.*?&", text: courseLink)
                            credits = crd.first!.substring(to: crd.first!.index(crd.first!.endIndex, offsetBy: -1))
                            credits = credits.substring(from: credits.index(credits.startIndex, offsetBy: 4))
                            
                            
                            courses.append(Course.init(name: name, code: code, credits: credits, preRequisite: preRequisite, url: url, abv: abv, courseNo: courseNo, departmentCode: departmentCode))
                        }

                    }
                }
                
            }
            
        }
        
        return courses
    }
    
    
    static func parseSections(_ html: String) -> [Section] {
        
        var sections = [Section]()
        
        var sectionNo: String = ""
        var doctor: String = ""
        var timing: [Timing] = []
        let note: String = ""
        var finalExam: FinalExam
        
        if let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8) {
            
            let tree = doc.xpath("//td | //font")
            
            var i = 0
            var c = 0
            
            /* it works, trust me;). I will write documentation later lol */
            for _ in tree {
                                
                if i >= c {
                    c += 1
                    continue
                }
                
                let secSearch = matchesForRegexInText(".*?Sec.*?\\[.*?", text: tree[i].text!)
                
                if secSearch.count > 0 {
                    
                    sectionNo = tree[i + 1].text!
                    doctor = tree[i + 3].text!.substring(to: tree[i + 3].text!.index(tree[i + 3].text!.endIndex, offsetBy: -1)).capitalized
                    
                    i += 10
                    while tree[i].text! != "Exam" {
                        
                        let day = tree[i].text!
                        let timeFrom = tree[i + 1].text!
                        let timeTo = tree[i + 2].text!
                        let room = tree[i + 3].text!
                        
                        timing.append(Timing.init(day: day, timeFrom: timeFrom, timeTo: timeTo, room: room))
                        
                        i += 4
                        
                    }
                    
                    var date: NSDate?
                    
                    if tree[i + 2].text!.characters.count == 10 {
                        date = Date(dateString: tree[i + 2].text!) as NSDate?
                    }
                            
                    let startTime = tree[i + 4].text!
                    let endTime = tree[i + 6].text!
                    
                    finalExam = FinalExam.init(date: date as Date?, startTime: startTime, endTime: endTime)
                    
                    sections.append(Section.init(sectionNo: sectionNo, doctor: doctor, seats: "0", timing: timing, note: note, finalExam: finalExam))
                    timing = []
                }
                
                i += 1
                c += 1
            
            }
        }
        
        return sections
    }
    
    static func parseSeats(_ html: String, sections: inout [Section]) {
        
        if let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8) {
            
            let tree = doc.xpath("//font")
            
            var i = 0
            
            for node in tree {
                
                let secSearch = matchesForRegexInText(".*?Sec.*?\\[.*?", text: node.text!)
                
                if secSearch.count > 0 {
                    let sectionNo = tree[i + 1].text!
                    let seats = tree[i + 5].text!
                    
                    for j in 0..<sections.count {
                        if sections[j].sectionNo == sectionNo {
                            sections[j].seats = seats
                        }
                    }
                }
                
                i += 1
            }
        }
    }
    
    static func matchesForRegexInText(_ regex: String!, text: String!) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex.matches(in: text,
                                                options: [], range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

extension Date
{
    init(dateString:String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "d-M-yyyy"
        dateStringFormatter.timeZone = TimeZone(identifier: "UTC")
        
        let d = dateStringFormatter.date(from: dateString)!
        self.init(timeInterval:0, since:d)
    }
    
    var formattedLong: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: self)
    }
}

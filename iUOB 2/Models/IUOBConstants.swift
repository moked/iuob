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
    
    static let baseURL = "https://www.something.edu.bh"   // change for the domain you want e.g. uob :-]
    
    static let sakheerLocation = Location(latitude: 26.051588, longitude: 50.513387)
    static let isaTownLocation = Location(latitude: 26.165126, longitude: 50.545274)
        
    static let depCodeMapping = ["ACC": "031", "ACCA": "A17", "ACCM": "131", "AH": "S20", "ALH": "S19", "AMST": "108", "ARAB": "047", "ARABA": "A24", "ARABM": "147", "ARCG": "292", "ART": "079", "BAA": "A40", "BIOLS": "087", "BIONU": "187", "BIS": "058", "CEA": "A25", "CEG": "112", "CENG": "325", "CGS": "S25", "CHE": "013", "CHEMY": "086", "CHENG": "353", "CHL": "114", "COM": "128", "CSA": "A13", "CSC": "081", "DH": "S23", "ECON": "034", "ECONA": "A18", "ECONM": "134", "EDAR": "366", "EDEG": "166", "EDPS": "177", "EDTC": "266", "EDU": "S30", "EEDA": "A29", "EEG": "110", "EENG": "345", "ELE": "S12", "ENG": "S28", "ENGG": "377", "ENGL": "049", "ENGL.": "D11", "ENGLA": "A11", "ENGLM": "149", "ENGLU": "009", "EPD": "S26", "ESD": "444", "ESP.": "D16", "ETDA": "A33", "EVALU": "195", "FA": "179", "FIN": "032", "FINA": "A21", "FINM": "132", "FOUN": "466", "FREN": "078", "GEOG": "076", "GERM": "107", "HIST": "075", "HISTO": "175", "HRLC": "771", "IEN": "002", "INTD": "191", "ISLM": "074", "IT": "558", "ITBIS": "158", "ITCE": "333", "ITCS": "222", "ITIS": "458", "JAPN": "100", "LAW": "080", "LAW.": "808", "LFS": "S24", "MATHA": "A12", "MATHS": "083", "MATHS.": "D15", "MCM": "228", "MEDA": "A30", "MEG": "111", "MENG": "314", "MGT": "030", "MGTA": "A15", "MISA": "A16", "MKT": "033", "MKTA": "A20", "MLS": "S32", "MLT": "S21", "MPHYS": "285", "NUR": "S11", "OMA": "A60", "PHA": "S18", "PHAM": "S31", "PHED": "001", "PHEDE": "200", "PHTY": "220", "PHYCS": "085", "PHYCSA": "A31", "PICDA": "A34", "PICENG": "355", "PSYC": "077", "PSYCH": "277", "QM": "035", "RAD": "S22", "SBF": "777", "SBS": "S27", "SOCIO": "173", "STAT": "096", "STATA": "A19", "TC1AR": "E27", "TC1ART": "E40", "TC1EN": "E28", "TC1IS": "E44", "TC1MA": "E25", "TC1MAT": "E39", "TC1SC": "E26", "TC1SCT": "E24", "TC2AR": "E35", "TC2ART": "E36", "TC2EN": "E33", "TC2ENT": "E34", "TC2IS": "E37", "TC2IST": "E38", "TC2MA": "E32", "TC2MAT": "E42", "TC2SC": "E31", "TC2SCT": "E41", "TCDE": "E12", "TCDEE": "E18", "TCDEGS": "E14", "TCDEIT": "E23", "TCDEM": "E13", "TCEL": "E45", "TCFN": "E55", "TCPB": "E11", "TOUR": "027", "TRAN": "082"]
    
    
    static func addToUserDefaults(_ course: String, section: String) {
        
        let defaults: UserDefaults = UserDefaults(suiteName: "group.com.muqdd.iuob")!
        //let defaults = UserDefaults.standard
        var courses = defaults.object(forKey: "SavedCoursesArray") as? [String] ?? [String]()
        var sections = defaults.object(forKey: "SavedSectionsArray") as? [String] ?? [String]()

        courses.append(course)
        sections.append(section)
        
        defaults.set(courses, forKey: "SavedCoursesArray")
        defaults.set(sections, forKey: "SavedSectionsArray")
        
        defaults.synchronize()
    }
    
    static func deleteFromUserDefaults(index: Int) {
        
        let defaults: UserDefaults = UserDefaults(suiteName: "group.com.muqdd.iuob")!
        var courses = defaults.object(forKey: "SavedCoursesArray") as? [String] ?? [String]()
        var sections = defaults.object(forKey: "SavedSectionsArray") as? [String] ?? [String]()
        
        defaults.set(nil, forKey: "\(courses[index])-\(sections[index])")

        courses.remove(at: index)
        sections.remove(at: index)
        
        defaults.set(courses, forKey: "SavedCoursesArray")
        defaults.set(sections, forKey: "SavedSectionsArray")
        
        defaults.synchronize()
    }

    static func getCoursesAndSections() -> (courses: [String], sections: [String]) {
        
        let defaults: UserDefaults = UserDefaults(suiteName: "group.com.muqdd.iuob")!
        let courses = defaults.object(forKey: "SavedCoursesArray") as? [String] ?? [String]()
        let sections = defaults.object(forKey: "SavedSectionsArray") as? [String] ?? [String]()
        
        return (courses, sections)
    }
    
//    static func suckCodes() {
//        
//        let url = "\(Constants.baseURL)/cgi/enr/schedule2.abrv"
//        
//        Alamofire.request(url, method: .get, parameters: ["prog": "1", "cyer": "2016", "csms": "1"])    // this shouldn't be hard coded
//            .validate()
//            .responseString { response in
//                
//                if response.result.error == nil {
//                    
//                    if let doc = Kanna.HTML(html: response.result.value!, encoding: String.Encoding.utf8) {
//                        
//                        for link in doc.xpath("//a") {
//                            
//                            if let depName = link.text, let depURL = link["href"] {
//                                
//                                let inl = UOBParser.matchesForRegexInText("inll=.*?&", text: depURL)
//                                var codee = inl.first!.substring(to: inl.first!.index(inl.first!.endIndex, offsetBy: -1))
//                                codee = codee.substring(from: codee.index(codee.startIndex, offsetBy: 5))
//                                
//                                print("\"\(depName)\": \"\(codee)\", ")
//                            }
//                        }
//                    }
//                    
//                } else {
//                    print("error man")
//                }
//        }
//    }
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

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

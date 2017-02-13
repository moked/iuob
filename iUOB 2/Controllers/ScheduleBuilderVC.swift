//
//  ScheduleBuilderVC.swift
//  iUOB 2
//
//  Created by Miqdad Altaitoon on 9/13/16.
//  Copyright © 2016 Miqdad Altaitoon. All rights reserved.
//

import UIKit

class ScheduleBuilderVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var semesterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var courseTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var nextButtonOutlet: UIBarButtonItem!
    
    var courses: [String] = []  // courses to be entered by user
    
    let allCoursesList = Constants.allCourses   // all uob courses list (for auto completion)
    var isFirstLoad: Bool = true    // to show empty state text on table view
    
    var autoCompleteViewController: AutoCompleteViewController!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButtonOutlet.isEnabled = false
        
        courseTextField.delegate = self
        
        let paddingView = UIView(frame:CGRect.init(x: 0, y: 0, width: 10, height: 30))
        courseTextField.leftView = paddingView;
        courseTextField.leftViewMode = UITextFieldViewMode.always
        
        courseTextField.becomeFirstResponder()
        
        googleAnalytics()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.isFirstLoad {
            self.isFirstLoad = false
            Autocomplete.setupAutocompleteForViewcontroller(self)
        }
    }
    
    func googleAnalytics() {
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: NSStringFromClass(type(of: self)).components(separatedBy: ".").last!)
            let builder: NSObject = GAIDictionaryBuilder.createScreenView().build()
            tracker.send(builder as! [NSObject : AnyObject])
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }
    
    @IBAction func addCourseButton(_ sender: AnyObject) {
        
        if (courseTextField.text?.characters.count)! < 3 {
            return
        }
        
        if validateCourse(course: courseTextField.text!) {
            
            courses.insert(courseTextField.text!, at: 0)    // insert at top
            
            nextButtonOutlet.isEnabled = true
            
            if  courses.count == 1 {
                
                tableView.reloadData()
            } else {
                let indexPath = IndexPath(row: 0, section: 0)
                tableView.insertRows(at: [indexPath], with: UITableViewRowAnimation.top)
            }
            
            courseTextField.text = ""
            
        } else {
            
        }
    }
    
    // MARK: - Table view data source & delegate
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        var numOfSections: Int = 0
        if courses.count > 0
        {
            tableView.separatorStyle = .singleLine
            numOfSections                = 1
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(tableView.bounds.size.width), height: CGFloat(tableView.bounds.size.height)))
            noDataLabel.text             = "Added courses will be here\n\n\n\n\n\n\n\n\n\n"
            noDataLabel.numberOfLines    = 0
            noDataLabel.textColor        = .black
            noDataLabel.textAlignment    = .center
            tableView.backgroundView     = noDataLabel
            tableView.separatorStyle     = .none
        }
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath)
        
        cell.textLabel?.text = courses[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.delete) {

            courses.remove(at: indexPath.row)
            
            if courses.count > 0 {
                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.right)
            } else {
                
                nextButtonOutlet.isEnabled = false
                tableView.reloadData()
            }

        }
    }
    
    
    /// Function to validate if the user entered a valid course or not
    /// based on: department code, last 3 digits, if already exists
    ///
    /// - Parameter course: course string
    /// - Returns: valid or not
    func validateCourse(course: String) -> Bool {
        
        let seperate = course.index(course.endIndex, offsetBy: -3)  // last three characters represent the courseNo e.g 101 in ITCS101
        let courseNo = course.substring(from: seperate)
        let department = course.substring(to: seperate)
        
        if let _ = Constants.depCodeMapping[department], let _ = Int(courseNo) {
            // if department is valid and last three digits are a number
            
            if self.courses.contains(course) {
                // already exists
                return false
            }
            
            return true
        }
        
        return false
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OptionsSegue" {
                
            let nextScene = segue.destination as? OptionsVC
            nextScene!.addedCourses = courses
            nextScene!.semester = self.semesterSegmentedControl.selectedSegmentIndex + 1
        }
    }
    
}

// MARK: - Autocomplete extenstion

extension ScheduleBuilderVC: AutocompleteDelegate {
    func autoCompleteTextField() -> UITextField {
        return self.courseTextField
    }
    func autoCompleteThreshold(_ textField: UITextField) -> Int {
        return 1
    }
    
    func autoCompleteItemsForSearchTerm(_ term: String) -> [AutocompletableOption] {
        let filteredCountries = self.allCoursesList.filter { (country) -> Bool in
            return country.lowercased().contains(term.lowercased())
        }
        
        let countriesAndFlags: [AutocompletableOption] = filteredCountries.map { ( country) -> AutocompleteCellData in
            var country = country
            country.replaceSubrange(country.startIndex...country.startIndex, with: String(country.characters[country.startIndex]).capitalized)
            return AutocompleteCellData(text: country, image: UIImage(named: country))
            }.map( { $0 as AutocompletableOption })
        
        return countriesAndFlags
    }
    
    func autoCompleteHeight() -> CGFloat {
        return self.view.frame.height / 3.0
    }
    
    
    func didSelectItem(_ item: AutocompletableOption) {
       // self.lblSelectedCountryName.text = item.text
        
        if validateCourse(course: item.text) {
            
            courses.insert(item.text, at: 0)
            
            nextButtonOutlet.isEnabled = true
            
            if  courses.count == 1 {
                
                tableView.reloadData()
            } else {
                let indexPath = IndexPath(row: 0, section: 0)
                tableView.insertRows(at: [indexPath], with: UITableViewRowAnimation.top)
            }
            
            courseTextField.text = ""
            
        } else {
            self.courseTextField.text = item.text
        }
        
        self.courseTextField.becomeFirstResponder()
    }
}

//
//  AutoCompleteViewController.swift
//  Autocomplete
//
//  Created by Amir Rezvani on 3/6/16.
//  Copyright © 2016 cjcoaxapps. All rights reserved.
//

import UIKit

let AutocompleteCellReuseIdentifier = "autocompleteCell"

open class AutoCompleteViewController: UIViewController {
    //MARK: - outlets
    @IBOutlet fileprivate weak var tableView: UITableView!

    //MARK: - internal items
    internal var autocompleteItems: [AutocompletableOption]?
    internal var cellHeight: CGFloat?
    internal var cellDataAssigner: ((_ cell: UITableViewCell, _ data: AutocompletableOption) -> Void)?
    internal var textField: UITextField?
    internal let animationDuration: TimeInterval = 0.2    

    //MARK: - private properties
    fileprivate var autocompleteThreshold: Int?
    fileprivate var maxHeight: CGFloat = 0
    fileprivate var height: CGFloat = 0

    //MARK: - public properties
    open weak var delegate: AutocompleteDelegate?

    //MARK: - view life cycle
    override open func viewDidLoad() {
        super.viewDidLoad()

        self.view.isHidden = true
        self.textField = self.delegate!.autoCompleteTextField()

        self.height = self.delegate!.autoCompleteHeight()
        self.view.frame = CGRect(x: self.textField!.frame.minX,
            y: self.textField!.frame.maxY,
            width: self.textField!.frame.width,
            height: self.height)

        self.tableView.register(self.delegate!.nibForAutoCompleteCell(), forCellReuseIdentifier: AutocompleteCellReuseIdentifier)

        self.textField?.addTarget(self, action: #selector(UITextInputDelegate.textDidChange(_:)), for: UIControlEvents.editingChanged)
        self.autocompleteThreshold = self.delegate!.autoCompleteThreshold(self.textField!)
        self.cellDataAssigner = self.delegate!.getCellDataAssigner()

        self.cellHeight = self.delegate!.heightForCells()
        // not to go beyond bound height if list of items is too big
        self.maxHeight = UIScreen.main.bounds.height - self.view.frame.minY
    }

    //MARK: - private methods
    @objc func textDidChange(_ textField: UITextField) {
        let numberOfCharacters = textField.text?.characters.count
        if let numberOfCharacters = numberOfCharacters {
            if numberOfCharacters > self.autocompleteThreshold! {
                self.view.isHidden = false
                guard let searchTerm = textField.text else { return }
                self.autocompleteItems = self.delegate!.autoCompleteItemsForSearchTerm(searchTerm)
                UIView.animate(withDuration: self.animationDuration,
                    delay: 0.0,
                    options: UIViewAnimationOptions(),
                    animations: { () -> Void in
                        self.view.frame.size.height = min(
                            CGFloat(self.autocompleteItems!.count) * CGFloat(self.cellHeight!),
                            self.maxHeight,
                            self.height
                        )
                    },
                    completion: nil)

                UIView.transition(with: self.tableView,
                    duration: self.animationDuration,
                    options: .transitionCrossDissolve,
                    animations: { () -> Void in
                        self.tableView.reloadData()
                    },
                    completion: nil)

            } else {
                self.view.isHidden = true
            }
        }
    }

}

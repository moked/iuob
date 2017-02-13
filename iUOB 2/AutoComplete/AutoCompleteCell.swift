//
//  AutoCompleteCell.swift
//  Autocomplete
//
//  Created by Amir Rezvani on 3/6/16.
//  Copyright © 2016 cjcoaxapps. All rights reserved.
//

import UIKit
open class AutoCompleteCell: UITableViewCell {
    //MARK: - outlets
    @IBOutlet fileprivate weak var lblTitle: UILabel!
    @IBOutlet fileprivate weak var imgIcon: UIImageView!

    //MARK: - public properties
    open var textImage: AutocompleteCellData? {
        didSet {
            self.lblTitle.text = textImage!.text
            self.imgIcon.image = textImage!.image
        }
    }
}

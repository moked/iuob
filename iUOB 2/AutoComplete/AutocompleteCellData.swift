//
//  AutocompleteCellData.swift
//  Autocomplete
//
//  Created by Amir Rezvani on 3/12/16.
//  Copyright © 2016 cjcoaxapps. All rights reserved.
//

import UIKit

public protocol AutocompletableOption {
    var text: String { get }
}

open class AutocompleteCellData: AutocompletableOption {
    fileprivate let _text: String
    open var text: String { get { return _text } }
    open let image: UIImage?

    public init(text: String, image: UIImage?) {
        self._text = text
        self.image = image
    }
}

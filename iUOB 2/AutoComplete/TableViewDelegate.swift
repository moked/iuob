//
//  TableViewDelegate.swift
//  Autocomplete
//
//  Created by Amir Rezvani on 3/6/16.
//  Copyright © 2016 cjcoaxapps. All rights reserved.
//

import UIKit

extension AutoCompleteViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeight!
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = self.autocompleteItems![(indexPath as NSIndexPath).row]
        self.textField?.text = selectedItem.text
        UIView.animate(withDuration: self.animationDuration, animations: { () -> Void in
                self.view.frame.size.height = 0.0
                self.textField?.endEditing(true)
            }, completion: { (completed) -> Void in
                self.delegate!.didSelectItem(selectedItem)
        }) 
    }
}

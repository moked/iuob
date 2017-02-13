//
//  TableViewDatasource.swift
//  Autocomplete
//
//  Created by Amir Rezvani on 3/6/16.
//  Copyright © 2016 cjcoaxapps. All rights reserved.
//

import UIKit

//MARK: UITableViewDataSource extension
extension AutoCompleteViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        if let items = self.autocompleteItems , items.count > 0 {
            return 1
        }
        return 0
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let items = self.autocompleteItems {
            return items.count
        }
        return 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        assert(self.autocompleteItems != nil, "item array was unexpectedlly nil")
        let items = self.autocompleteItems!
        let cell = tableView.dequeueReusableCell(withIdentifier: "autocompleteCell", for: indexPath)
        let data = items[(indexPath as NSIndexPath).row]
        self.cellDataAssigner!(cell, data)
        return cell
    }
}

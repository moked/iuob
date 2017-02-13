//
//  Autocomplete.swift
//  Autocomplete
//
//  Created by Amir Rezvani on 3/6/16.
//  Copyright © 2016 cjcoaxapps. All rights reserved.
//

import UIKit
open class Autocomplete {
    open class func setupAutocompleteForViewcontroller<T: UIViewController>(_ viewController: T) where T: AutocompleteDelegate {
        let autoCompleteViewController = initAutoCompleteVC()
        autoCompleteViewController.delegate = viewController

        setupUI(autoCompleteViewController, parentViewController: viewController)

    }
    open class func setupAutocompleteForViewcontrollerWithDetachedDelegate(_ viewController: UIViewController, delegate:AutocompleteDelegate) {
        let autoCompleteViewController = initAutoCompleteVC()
        autoCompleteViewController.delegate = delegate
        
        setupUI(autoCompleteViewController, parentViewController: viewController)
        
    }
    
    fileprivate class func initAutoCompleteVC() -> AutoCompleteViewController {
        let podBundle: Bundle = Bundle(for: Autocomplete.self)
        
        let storyboard = UIStoryboard(name: "Autocomplete", bundle: podBundle)
        return storyboard.instantiateViewController(withIdentifier: "autocompleteScene") as! AutoCompleteViewController
    }
    
    fileprivate class func setupUI(_ autoCompleteViewController: AutoCompleteViewController, parentViewController: UIViewController) {
        //Remove from any superview and super viewcontrollers
        autoCompleteViewController.view.removeFromSuperview()
        autoCompleteViewController.removeFromParentViewController()
        
        autoCompleteViewController.willMove(toParentViewController: parentViewController)
        parentViewController.addChildViewController(autoCompleteViewController)
        autoCompleteViewController.didMove(toParentViewController: parentViewController)
        
        autoCompleteViewController.view.willMove(toSuperview: parentViewController.view)
        parentViewController.view.addSubview(autoCompleteViewController.view)
        autoCompleteViewController.view.didMoveToSuperview()
    }
}

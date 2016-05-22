//
//  Extensions.swift
//  TFG
//
//  Created by Johannes Berger on 07.04.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit

///Extensions to the UIViewController 
extension UIViewController {
    ///Extension that hides the keyboard when a user tapps somewhere outside the textfield
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    ///Dismisses the kexboard
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
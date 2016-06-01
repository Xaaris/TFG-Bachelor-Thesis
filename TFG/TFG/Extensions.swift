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

extension UILabel{
    
    func requiredHeight() -> CGFloat{
        
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, self.frame.width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = self.font
        label.text = self.text
        
        label.sizeToFit()
        
        return label.frame.height
    }
}
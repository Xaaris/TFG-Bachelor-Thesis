//
//  ForgotPasswordViewController.swift
//  TFG
//
//  Created by Johannes Berger on 07.04.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit
import Parse

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func passwordResetButtonPressed(sender: AnyObject) {
        let email = self.emailField.text!
        let finalEmail = email.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        //Check online connectivity
        let status = Reach().connectionStatus()
        switch status{
        case .Unknown, .Offline:
            showAlert("No connection", message: "You need an internet connection to be able to reset your password")
        default:
            
            if finalEmail.characters.count < 5 {
                showAlert("Invalid", message: "Please enter a valid email address")
            } else {
                
                // Run a spinner to show a task in progress
                activityIndicator.startAnimating()
                UIApplication.sharedApplication().beginIgnoringInteractionEvents()
                
                // Send a request to reset a password
                PFUser.requestPasswordResetForEmailInBackground(finalEmail, block: { (succeed, error) in
                    
                    // Stop the spinner
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if ((error) != nil) {
                        self.showAlert("Error", message: "\(error!.userInfo["error"] as! String)")
                        
                    } else {
                        self.showAlert("Password Reset", message: "An email containing information on how to reset your password has been sent to " + finalEmail + ".")
                    }
                })
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
}

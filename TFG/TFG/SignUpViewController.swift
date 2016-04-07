//
//  SignUpViewController.swift
//  TFG
//
//  Created by Johannes Berger on 07.04.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func signUpButtonPressed(sender: AnyObject) {
        
        let username = self.usernameField.text!
        let password = self.passwordField.text!
        let email = self.emailField.text!
        let finalEmail = email.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        // Validate the text fields
        if username.characters.count < 5 {
            showAlert("Invalid", message: "Username must be greater than 5 characters")
        } else if password.characters.count < 8 {
            showAlert("Invalid", message: "Password must be greater than 8 characters")
        } else if email.characters.count < 8 {
            showAlert("Invalid", message: "Please enter a valid email address")
        } else {
            // Run a spinner to show a task in progress
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            let newUser = PFUser()
            newUser.username = username
            newUser.password = password
            newUser.email = finalEmail
            
            // Sign up the user asynchronously
            newUser.signUpInBackgroundWithBlock({ (succeed, error) -> Void in
                
                // Stop the spinner
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                if ((error) != nil) {
                    self.showAlert("Error", message: "\(error!.userInfo["error"] as! String)")
                    
                } else {
                    
                    let alertController = UIAlertController(title: "Success", message: "You are signed up!", preferredStyle: UIAlertControllerStyle.Alert)
                    let dismissVCAction = UIAlertAction(title: "Great!", style: .Default) { (action) in
                        self.goBackToLogin()
                    }
                    alertController.addAction(dismissVCAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            })
        }
    }
    
    func goBackToLogin(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
}

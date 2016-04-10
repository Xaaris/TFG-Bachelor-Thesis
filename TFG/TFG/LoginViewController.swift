//
//  LoginViewController.swift
//  TFG
//
//  Created by Johannes Berger on 06.04.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(animated: Bool) {
        //Dismiss Login view if sign up successful
        if (PFUser.currentUser() != nil) {
            dismissKeyboard()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        let username = self.usernameField.text!
        let password = self.passwordField.text!
        
        //Check online connectivity
        let status = Reach().connectionStatus()
        switch status{
        case .Unknown, .Offline:
            showAlert("No connection", message: "You need an internet connection to be able to log in")
        default:
            // Validate the text fields
            if username.characters.count < 5 {
                showAlert("Invalid", message: "Username must be greater than 5 characters")
            } else if password.characters.count < 8 {
                showAlert("Invalid", message: "Password must be greater than 8 characters")
            } else {
                // Run a spinner to show a task in progress
                activityIndicator.startAnimating()
                UIApplication.sharedApplication().beginIgnoringInteractionEvents()
                
                // Send a request to login
                PFUser.logInWithUsernameInBackground(username, password: password, block: { (user, error) -> Void in
                    
                    // Stop the spinner
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if ((user) != nil) {
                        //User logged in successfully!
                        self.dismissKeyboard()
                        self.loadDataFromCloud()
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        self.showAlert("Error", message: "\(error!.userInfo["error"] as! String)")
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
    
    @IBAction func unwindToLogInScreen(segue:UIStoryboardSegue) {
    }
    
    func loadDataFromCloud(){
        CloudLink.syncPreferencesToRealm()
        CloudLink.syncStatisticsToRealm()
    }
    
    
}



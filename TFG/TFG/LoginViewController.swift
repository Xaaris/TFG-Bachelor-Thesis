//
//  LoginViewController.swift
//  TFG
//
//  Created by Johannes Berger on 06.04.16.
//  Copyright © 2016 Johannes Berger. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    ///Sets delegates and initializes hideKeyboardWhenTappedAround
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        usernameField.delegate = self
        passwordField.delegate = self
    }
    
    ///When User just signed up go directly into the app
    override func viewDidAppear(animated: Bool) {
        //Dismiss Login view if sign up successful
        if (PFUser.currentUser() != nil) {
            dismissKeyboard()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    /** Method that ensures cursor is jumping to next text field when the enter key was tapped
        Parameter textField: the current textfield the cursor is in
        Returns: always true
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameField{
            passwordField.becomeFirstResponder()
        }else if textField == passwordField{
            validateAndLogIn()
        }
        return true
    }
    
    /// Invoked when the Login button was pressed or the return key was hit on the last text field
    @IBAction func loginButtonPressed(sender: AnyObject) {
        validateAndLogIn()
    }
    
    ///Starts validation process and if successful starts login process
    func validateAndLogIn(){
        if validateTextFieldValues(){
            let username = self.usernameField.text!
            let password = self.passwordField.text!
            login(username, password: password)
        }
    }
    
  
    
    /**
     Checks if data in the textfields is correct. If not it shows an alert
     - returns: true if all textfields contain valid data, else false
     */
    func validateTextFieldValues() -> Bool{
        let username = self.usernameField.text!
        let password = self.passwordField.text!
        
        var title = ""
        var message = ""
        
        //Check online connectivity
        if !CloudLink.isConnected(){
            title = NSLocalizedString("No connection", comment: "")
            message = NSLocalizedString("You need an internet connection to be able to log in", comment: "")
            // Validate the text fields
        } else if username.characters.count < 4 {
            title = NSLocalizedString("Invalid", comment: "")
            message = NSLocalizedString("Username must be greater than 4 characters", comment: "")
        } else if password.characters.count < 6 {
            title = NSLocalizedString("Invalid", comment: "")
            message = NSLocalizedString("Password must be greater than 6 characters", comment: "")
        } else {
            return true
        }
        showAlert(title, message: message)
        return false
    }
    
    
    /**
     Starts Login process
     - parameters:
       - username: Username as String
       - password: Password as String
     */
    func login(username: String, password: String){
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
                CloudLink.syncAllDataToRealm()
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                self.showAlert("Error", message: "\(error!.userInfo["error"] as! String)")
            }
        })

    }
    
    /**
     Shows an overlay alert with an "OK" button to dimiss it
     - parameters:
        - title: Title of the alert
        - message: body of the alert
     */
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func unwindToLogInScreen(segue:UIStoryboardSegue) {
    }
    
    
}



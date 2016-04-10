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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        usernameField.delegate = self
        passwordField.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        //Dismiss Login view if sign up successful
        if (PFUser.currentUser() != nil) {
            dismissKeyboard()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameField{
            passwordField.becomeFirstResponder()
        }else if textField == passwordField{
            validateAndLogIn()
        }
        return true
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        validateAndLogIn()
    }
    
    func validateAndLogIn(){
        if validateTextFieldValues(){
            let username = self.usernameField.text!
            let password = self.passwordField.text!
            login(username, password: password)
        }
    }
    
    func validateTextFieldValues() -> Bool{
        let username = self.usernameField.text!
        let password = self.passwordField.text!
        
        //Check online connectivity
        if !Util.isConnected(){
            showAlert("No connection", message: "You need an internet connection to be able to log in")
            // Validate the text fields
        } else if username.characters.count < 4 {
            showAlert("Invalid", message: "Username must be greater than 4 characters")
        } else if password.characters.count < 6 {
            showAlert("Invalid", message: "Password must be greater than 6 characters")
        } else {
            return true
        }
        return false
    }
    
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
                self.loadDataFromCloud()
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                self.showAlert("Error", message: "\(error!.userInfo["error"] as! String)")
            }
        })

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


